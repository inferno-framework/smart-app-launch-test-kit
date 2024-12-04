require_relative '../../lib/smart_app_launch/token_exchange_test'
require_relative '../request_helper'

RSpec.describe SMARTAppLaunch::TokenExchangeTest do
  include Rack::Test::Methods
  include RequestHelpers

  let(:test) { Inferno::Repositories::Tests.new.find('smart_token_exchange') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart') }
  let(:url) { 'http://example.com/fhir' }
  let(:token_url) { 'http://example.com/token' }
  let(:public_inputs) do
    base_inputs = {
      code: 'CODE',
      smart_token_url: token_url,
      client_id: 'CLIENT_ID',
      pkce_support: 'disabled'
    }

    if SMARTAppLaunch::Feature.use_auth_info?
      base_inputs.merge(
        auth_info: Inferno::DSL::AuthInfo.new(
          client_id: base_inputs[:client_id],
          pkce_support: base_inputs[:pkce_support]
        )
      ).except(:client_id, :pkce_support)
    else
      base_inputs
    end
  end
  let(:confidential_inputs) do
    if SMARTAppLaunch::Feature.use_auth_info?
      public_inputs[:auth_info].client_secret = 'CLIENT_SECRET'
      public_inputs
    else
      public_inputs.merge(
        client_secret: 'CLIENT_SECRET'
      )
    end
  end

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      type = runnable.config.input_type(name)
      type = 'text' if type == 'radio'
      session_data_repo.save(
        test_session_id: test_session.id,
        name: name,
        value: value,
        type: type
      )
    end
    Inferno::TestRunner.new(test_session: test_session, test_run: test_run).run(runnable)
  end

  def create_redirect_request(url)
    repo_create(
      :request,
      direction: 'incoming',
      name: 'redirect',
      url: url,
      test_session_id: test_session.id
    )
  end

  context 'with a confidential client' do
    it 'passes if the token response has a 200 status' do
      create_redirect_request('http://example.com/redirect?code=CODE')
      stub_request(:post, token_url)
        .with(
          body:
            {
              grant_type: 'authorization_code',
              code: 'CODE',
              redirect_uri: "#{Inferno::Application['base_url']}/custom/smart/redirect"
            },
          headers: { 'Authorization' => "Basic #{Base64.strict_encode64('CLIENT_ID:CLIENT_SECRET')}" }
        )
        .to_return(status: 200, body: {}.to_json)

      result = run(test, confidential_inputs)

      expect(result.result).to eq('pass')
    end
  end

  context 'with a public client' do
    it 'passes if the token response has a 200 status' do
      create_redirect_request('http://example.com/redirect?code=CODE')
      stub_request(:post, token_url)
        .with(
          body:
            {
              grant_type: 'authorization_code',
              code: 'CODE',
              client_id: 'CLIENT_ID',
              redirect_uri: described_class.config.options[:redirect_uri]
            }
        )
        .to_return(status: 200, body: {}.to_json)

      result = run(test, public_inputs)

      expect(result.result).to eq('pass')
    end
  end

  it 'fails if a non-200 response is received' do
    create_redirect_request('http://example.com/redirect?code=CODE')
    stub_request(:post, token_url)
      .with(
        body:
          {
            grant_type: 'authorization_code',
            code: 'CODE',
            client_id: 'CLIENT_ID',
            redirect_uri: described_class.config.options[:redirect_uri]
          }
      )
      .to_return(status: 201)

    result = run(test, public_inputs)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status/)
  end

  it 'skips if the auth request had an error' do
    create_redirect_request('http://example.com/redirect?code=CODE&error=invalid_request')

    result = run(test, public_inputs)

    expect(result.result).to eq('skip')
    expect(result.result_message).to eq('Error during authorization request')
  end

  context 'with PKCE support' do
    it 'sends the code verifier' do
      create_redirect_request('http://example.com/redirect?code=CODE')
      token_request =
        stub_request(:post, token_url)
        .with(
          body:
            {
              grant_type: 'authorization_code',
              code: 'CODE',
              client_id: 'CLIENT_ID',
              redirect_uri: described_class.config.options[:redirect_uri],
              code_verifier: 'CODE_VERIFIER'
            }
        )
        .to_return(status: 200, body: {}.to_json)

      if SMARTAppLaunch::Feature.use_auth_info?
        public_inputs[:auth_info].pkce_support = 'enabled'
      else
        public_inputs[:pkce_support] = 'enabled'
      end
      public_inputs[:pkce_code_verifier] = 'CODE_VERIFIER'
      result = run(test, public_inputs)

      expect(result.result).to eq('pass')
      expect(token_request).to have_been_made
    end
  end
end
