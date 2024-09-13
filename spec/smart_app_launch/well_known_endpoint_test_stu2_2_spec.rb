require_relative '../../lib/smart_app_launch/well_known_endpoint_test_stu2_2'

RSpec.describe SMARTAppLaunch::WellKnownEndpointSTU22Test do
  let(:runnable) { Inferno::Repositories::Tests.new.find('well_known_endpoint_stu2_2') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_stu2_2') }
  let(:url) { 'http://example.com/fhir' }
  let(:well_known_url) { 'http://example.com/fhir/.well-known/smart-configuration' }
  let(:well_known_config) do
    {
      'authorization_endpoint' => 'https://example.com/fhir/auth/authorize',
      'token_endpoint' => 'https://example.com/fhir/auth/token',
      'token_endpoint_auth_methods_supported' => ['client_secret_basic'],
      'registration_endpoint' => 'https://example.com/fhir/auth/register',
      'scopes_supported' =>
        ['openid', 'profile', 'launch', 'launch/patient', 'patient/*.*', 'user/*.*', 'offline_access'],
      'response_types_supported' => ['code', 'code id_token', 'id_token', 'refresh_token'],
      'management_endpoint' => 'https://example.com/fhir/user/manage',
      'introspection_endpoint' => 'https://example.com/fhir/user/introspect',
      'revocation_endpoint' => 'https://example.com/fhir/user/revoke',
      'capabilities' =>
        ['launch-ehr', 'client-public', 'client-confidential-symmetric', 'context-ehr-patient', 'sso-openid-connect'],
      'issuer' => 'https://example.com',
      'jwks_uri' => 'https://example.com/.well-known/jwks.json',
      'grant_types_supported' => ['authorization_code'],
      'code_challenge_methods_supported' => ['S256']
    }
  end

  let(:relative_well_known_config) do
    {
      'authorization_endpoint' => 'authorize',
      'token_endpoint' => 'http://foobar.quz/token',
      'token_endpoint_auth_methods_supported' => ['client_secret_basic'],
      'registration_endpoint' => '/auth/register',
      'scopes_supported' =>
        ['openid', 'profile', 'launch', 'launch/patient', 'patient/*.*', 'user/*.*', 'offline_access'],
      'response_types_supported' => ['code', 'code id_token', 'id_token', 'refresh_token'],
      'management_endpoint' => 'user/manage',
      'introspection_endpoint' => '/introspect',
      'revocation_endpoint' => 'https://example.com/fhir/user/revoke',
      'capabilities' =>
        ['launch-ehr', 'client-public', 'client-confidential-symmetric', 'context-ehr-patient', 'sso-openid-connect'],
      'issuer' => 'https://example.com',
      'jwks_uri' => 'https://example.com/.well-known/jwks.json',
      'grant_types_supported' => ['authorization_code'],
      'code_challenge_methods_supported' => ['S256']
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
        type: runnable.config.input_type(name)
      )
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable)
  end

  it 'passes when a valid well-known configuration is received' do
    stub_request(:get, well_known_url)
      .to_return(status: 200, body: well_known_config.to_json, headers:
      { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => Inferno::Application['base_url'] })
    result = run(runnable, url:)

    expect(result.result).to eq('pass')
  end

  it 'passes when a valid well-known configuration is received with relative SMART URLs' do
    stub_request(:get, well_known_url)
      .to_return(status: 200, body: relative_well_known_config.to_json, headers:
      { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => Inferno::Application['base_url'] })
    result = run(runnable, url:)

    expect(result.result).to eq('pass')
  end

  it 'converts relative URLs to absolute URLs' do
    stub_request(:get, well_known_url)
      .to_return(status: 200, body: relative_well_known_config.to_json, headers:
      { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => Inferno::Application['base_url'] })

    run(runnable, url:)

    expected_outputs = {
      well_known_authorization_url: 'http://example.com/fhir/authorize',
      well_known_introspection_url: 'http://example.com/introspect',
      well_known_management_url: 'http://example.com/fhir/user/manage',
      well_known_registration_url: 'http://example.com/auth/register',
      well_known_revocation_url: 'https://example.com/fhir/user/revoke',
      well_known_token_url: 'http://foobar.quz/token'
    }

    expected_outputs.each do |name, value|
      expect(session_data_repo.load(test_session_id: test_session.id, name:)).to eq(value.to_s)
    end
  end

  it 'sends an Accept Header with application/json' do
    stub_request(:get, well_known_url)
      .with(headers: { 'Accept' => 'application/json' })
      .to_return(status: 200, body: well_known_config.to_json, headers:
      { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => Inferno::Application['base_url'] })
    result = run(runnable, url:)

    expect(result.result).to eq('pass')
  end

  it 'fails when a non-200 response is received' do
    stub_request(:get, well_known_url)
      .to_return(status: 201, body: well_known_config.to_json, headers:
      { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => Inferno::Application['base_url'] })
    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status:/)
  end

  it 'fails when an incorrect CORs header is received' do
    stub_request(:get, well_known_url)
      .to_return(status: 200, body: well_known_config.to_json, headers:
      { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => 'https://incorrect-origin.com' })
    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/`Access-Control-Allow-Origin` must be/)
  end

  it 'fails when no CORs header is received' do
    stub_request(:get, well_known_url)
      .to_return(status: 200, body: well_known_config.to_json, headers:
      { 'Content-Type' => 'application/json' })
    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match('No `Access-Control-Allow-Origin` header received')
  end

  it 'fails when a Content-Type header is not received' do
    stub_request(:get, well_known_url)
      .to_return(status: 200, body: well_known_config.to_json)
    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/No.*header received/)
  end

  it 'fails when an incorrect Content-Type header is received' do
    stub_request(:get, well_known_url)
      .to_return(status: 200, body: well_known_config.to_json, headers:
      { 'Content-Type' => 'application/xml', 'Access-Control-Allow-Origin' => Inferno::Application['base_url'] })
    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(%r{`Content-Type` must be `application/json`})
  end

  it 'fails when the body is invalid json' do
    stub_request(:get, well_known_url)
      .to_return(status: 200, body: '[[', headers:
      { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => Inferno::Application['base_url'] })
    result = run(runnable, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Invalid JSON/)
  end

  it 'persists outputs' do
    stub_request(:get, well_known_url)
      .to_return(status: 200, body: well_known_config.to_json, headers:
      { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => Inferno::Application['base_url'] })
    run(runnable, url:)
    ['authorization', 'introspection', 'management', 'registration', 'revocation', 'token'].each do |type|
      value = session_data_repo.load(test_session_id: test_session.id, name: "well_known_#{type}_url")
      expect(value).to be_present
      expect(value).to eq(well_known_config["#{type}_endpoint"])
    end

    expect(session_data_repo.load(test_session_id: test_session.id, name: 'well_known_configuration'))
      .to eq(well_known_config.to_json)
  end
end
