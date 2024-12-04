require_relative '../../lib/smart_app_launch/token_refresh_stu2_test'
require_relative '../request_helper'

RSpec.describe SMARTAppLaunch::TokenRefreshSTU2Test do
  include Rack::Test::Methods
  include RequestHelpers

  let(:test) { Inferno::Repositories::Tests.new.find('smart_token_refresh_stu2') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:requests_repo) { Inferno::Repositories::Requests.new }
  let(:suite_id) { 'smart'}
  let(:token_url) { 'http://example.com/fhir/token' }
  let(:refresh_token) { 'REFRESH_TOKEN' }
  let(:client_id) { 'CLIENT_ID' }
  let(:client_secret) { 'CLIENT_SECRET' }
  let(:received_scopes) { 'openid profile launch offline_access patient/*.*' }
  let(:valid_response) do
    {
      access_token: 'ACCESS_TOKEN',
      token_type: 'Bearer',
      expires_in: 3600,
      scope: received_scopes,
      refresh_token: 'REFRESH_TOKEN2'
    }
  end

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(
        test_session_id: test_session.id,
        name:,
        value:,
        type: runnable.config.input_type(name) || 'text'
      )
    end
    Inferno::TestRunner.new(test_session: test_session, test_run: test_run).run(runnable)
  end

  it 'skips if no refresh_token is available' do
    result = run(test, refresh_token: nil)

    expect(result.result).to eq('skip')
  end

  context 'with a public client' do
    let(:client_auth_type) { 'public' }

    it 'passes when the refresh succeeds' do
      stub_request(:post, token_url)
        .to_return(
          status: 200,
          headers: {
            'Content-Type': 'application/json'
          },
          body: valid_response.to_json
        )

      result = run(
        test,
        smart_token_url: token_url,
        refresh_token:,
        client_id:,
        received_scopes:,
        client_auth_type:
      )

      expect(result.result).to eq('pass')
    end
  end

  context 'with a confidential symmetric client' do
    let(:client_auth_type) { 'confidential_symmetric' }

    it 'passes when the refresh succeeds' do
      credentials = Base64.strict_encode64("#{client_id}:#{client_secret}")
      stub_request(:post, token_url)
        .with(
          headers: {
            Authorization: "Basic #{credentials}"
          }
        )
        .to_return(
          status: 200,
          headers: {
            'Content-Type': 'application/json'
          },
          body: valid_response.to_json
        )

      base_inputs = {
        smart_token_url: token_url,
        refresh_token:,
        client_id:,
        client_secret:,
        received_scopes:,
        client_auth_type:
      }
      inputs = if SMARTAppLaunch::Feature.use_auth_info?
                 base_inputs.merge(
                   auth_info: Inferno::DSL::AuthInfo.new(
                     client_id: base_inputs[:client_id],
                     client_secret: base_inputs[:client_secret]
                   )
                 ).except(:client_id, :client_secret)
               else
                 base_inputs
               end
      result = run(test, inputs)
      expect(result.result).to eq('pass')
    end
  end

  context 'with a confidential asymmetric client' do
    let(:client_auth_type) { 'confidential_asymmetric' }

    it 'passes when the refresh succeeds' do
      stub_request(:post, token_url)
        .to_return(
          status: 200,
          headers: {
            'Content-Type': 'application/json'
          },
          body: valid_response.to_json
        )

      result = run(
        test,
        smart_token_url: token_url,
        refresh_token:,
        client_id:,
        client_secret:,
        received_scopes:,
        client_auth_type:,
        client_auth_encryption_method: 'RS384'
      )

      expect(result.result).to eq('pass')
    end
  end

  it 'fails if a non-200/201 response is received' do
    stub_request(:post, token_url)
      .to_return(
        status: 202,
        headers: {
          'Content-Type': 'application/json'
        },
        body: valid_response.to_json
      )

    result = run(
      test,
      smart_token_url: token_url,
      refresh_token:,
      client_id:,
      received_scopes:,
      client_auth_type: 'public'
    )

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/202/)
  end

  it 'fails if a non-json response is received' do
    stub_request(:post, token_url)
      .to_return(
        status: 200,
        headers: {
          'Content-Type': 'application/json'
        },
        body: '[['
      )

    result = run(
      test,
      smart_token_url: token_url,
      refresh_token:,
      client_id:,
      received_scopes:,
      client_auth_type: 'public'
    )

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Invalid JSON/)
  end

  it 'persists request' do
    stub_request(:post, token_url)
      .to_return(
        status: 200,
        headers: {
          'Content-Type': 'application/json'
        },
        body: valid_response.to_json
      )

    result = run(
      test,
      smart_token_url: token_url,
      refresh_token:,
      client_id:,
      received_scopes:,
      client_auth_type: 'public'
    )

    expect(result.result).to eq('pass')

    request = requests_repo.find_named_request(test_session.id, :token_refresh)
    expect(request).to be_present
  end

  context 'when the response does not contain a refresh token' do
    it 'includes the original refresh token in the smart credentials' do
      stub_request(:post, token_url)
        .to_return(
          status: 200,
          headers: {
            'Content-Type': 'application/json'
          },
          body: valid_response.except(:refresh_token).to_json
        )

      result = run(
        test,
        smart_token_url: token_url,
        refresh_token:,
        client_id:,
        received_scopes:,
        client_auth_type: 'public'
      )

      expect(result.result).to eq('pass')

      smart_credentials =
        JSON.parse(
          session_data_repo.load(
            test_session_id: test_session.id,
            name: :smart_credentials
          )
        ).symbolize_keys

      expect(smart_credentials[:refresh_token]).to eq(refresh_token)
    end
  end
end
