require_relative '../../lib/smart_app_launch/cors_token_exchange_test'

RSpec.describe SMARTAppLaunch::CORSTokenExchangeTest do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('smart_stu2_2') }
  let(:test) { Inferno::Repositories::Tests.new.find('smart_cors_token_exchange') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_stu2_2') }
  let(:url) { 'http://example.com/fhir' }
  let(:token_url) { 'http://example.com/token' }
  let(:client_id) { 'CLIENT_ID' }
  let(:client_auth_encryption_method) { 'ES384' }

  let(:inputs) do
    {
      code: 'CODE',
      smart_token_url: token_url,
      client_id:,
      client_auth_type: 'confidential_asymmetric',
      client_auth_encryption_method:,
      use_pkce: 'false'
    }
  end

  def create_redirect_request(url)
    repo_create(
      :request,
      direction: 'incoming',
      name: 'redirect',
      url:,
      test_session_id: test_session.id
    )
  end

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      type = runnable.config.input_type(name)
      type = 'text' if type == 'radio'
      session_data_repo.save(
        test_session_id: test_session.id,
        name:,
        value:,
        type: type.presence
      )
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable)
  end

  def cors_header(value)
    {
      'Access-Control-Allow-Origin' => value
    }
  end

  it 'passes if the token response is returned with valid origin cors header' do
    create_redirect_request('http://example.com/redirect?code=CODE')
    token_exchange = stub_request(:post, token_url)
      .with(
        body: hash_including(
          {
            grant_type: 'authorization_code',
            code: 'CODE',
            redirect_uri: "#{Inferno::Application['base_url']}/custom/smart/redirect",
            client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
          }
        )
      )
      .to_return(status: 200, body: {}.to_json, headers: cors_header(Inferno::Application['inferno_host']))

    result = run(test, inputs)

    expect(result.result).to eq('pass')
    expect(token_exchange).to have_been_made
  end

  it 'passes if the token response is returned with valid wildcard cors header' do
    create_redirect_request('http://example.com/redirect?code=CODE')
    token_exchange = stub_request(:post, token_url)
      .with(
        body: hash_including(
          {
            grant_type: 'authorization_code',
            code: 'CODE',
            redirect_uri: "#{Inferno::Application['base_url']}/custom/smart/redirect",
            client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
          }
        )
      )
      .to_return(status: 200, body: {}.to_json, headers: cors_header('*'))

    result = run(test, inputs)

    expect(result.result).to eq('pass')
    expect(token_exchange).to have_been_made
  end

  it 'fails when a non-200 response is received' do
    create_redirect_request('http://example.com/redirect?code=CODE')
    token_exchange = stub_request(:post, token_url)
      .with(
        body: hash_including(
          {
            grant_type: 'authorization_code',
            code: 'CODE',
            redirect_uri: "#{Inferno::Application['base_url']}/custom/smart/redirect",
            client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
          }
        )
      )
      .to_return(status: 500, body: {}.to_json, headers: cors_header(Inferno::Application['inferno_host']))

    result = run(test, inputs)

    expect(result.result).to eq('fail')
    expect(token_exchange).to have_been_made
    expect(result.result_message).to match(/Unexpected response status/)
  end

  it 'fails if the token response with no cors header is received' do
    create_redirect_request('http://example.com/redirect?code=CODE')
    token_exchange = stub_request(:post, token_url)
      .with(
        body: hash_including(
          {
            grant_type: 'authorization_code',
            code: 'CODE',
            redirect_uri: "#{Inferno::Application['base_url']}/custom/smart/redirect",
            client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
          }
        )
      )
      .to_return(status: 200, body: {}.to_json)

    result = run(test, inputs)

    expect(result.result).to eq('fail')
    expect(token_exchange).to have_been_made
    expect(result.result_message).to match('No `Access-Control-Allow-Origin` header received')
  end

  it 'fails if the token response with incorrect cors header is received' do
    create_redirect_request('http://example.com/redirect?code=CODE')
    token_exchange = stub_request(:post, token_url)
      .with(
        body: hash_including(
          {
            grant_type: 'authorization_code',
            code: 'CODE',
            redirect_uri: "#{Inferno::Application['base_url']}/custom/smart/redirect",
            client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
          }
        )
      )
      .to_return(status: 200, body: {}.to_json, headers: cors_header('https://incorrect-origin.com'))

    result = run(test, inputs)

    expect(result.result).to eq('fail')
    expect(token_exchange).to have_been_made
    expect(result.result_message).to match(/`Access-Control-Allow-Origin` must be/)
  end
end
