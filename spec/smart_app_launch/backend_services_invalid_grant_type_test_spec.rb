require_relative '../../lib/smart_app_launch/backend_services_invalid_grant_type_test'
require_relative '../../lib/smart_app_launch/backend_services_authorization_request_builder'

RSpec.describe SMARTAppLaunch::BackendServicesInvalidGrantTypeTest do
  let(:test) { Inferno::Repositories::Tests.new.find('smart_backend_services_invalid_grant_type') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_stu2') }
  let(:smart_token_url) { 'http://example.com/fhir/token' }
  let(:client_auth_encryption_method) { 'ES384' }
  let(:backend_services_requested_scope) { 'system/Patient.read' }
  let(:backend_services_client_id) { 'clientID' }
  let(:exp) { 5.minutes.from_now }
  let(:jti) { SecureRandom.hex(32) }
  let(:request_builder) { BackendServicesAuthorizationRequestBuilder.new(builder_input) }
  let(:client_assertion) { create_client_assertion(client_assertion_input) }
  let(:body) { request_builder.authorization_request_query_values }
  let(:input) do
    {
      smart_auth_info: Inferno::DSL::AuthInfo.new(
        auth_type: 'backend_services',
        client_id: backend_services_client_id,
        requested_scopes: backend_services_requested_scope,
        encryption_algorithm: client_auth_encryption_method,
        token_url: smart_token_url
      )
    }
  end
  let(:builder_input) do
    {
      encryption_method: client_auth_encryption_method,
      scope: backend_services_requested_scope,
      iss: backend_services_client_id,
      sub: backend_services_client_id,
      aud: smart_token_url,
      exp:,
      jti:,
      kid:
    }
  end

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(
        test_session_id: test_session.id,
        name: name,
        value: value,
        type: runnable.config.input_type(name)
      )
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable)
  end

  it 'fails when token endpoint allows invalid grant_type' do
    stub_request(:post, smart_token_url)
      .with(body: hash_including(grant_type: 'not_a_grant_type'))
      .to_return(status: 200)

    result = run(test, input)

    expect(result.result).to eq('fail')
    expect(result.result_message).to eq('Unexpected response status: expected 400, but received 200')
  end

  it 'passes when token endpoint requires valid grant_type' do
    stub_request(:post, smart_token_url)
      .with(body: hash_including(grant_type: 'not_a_grant_type'))
      .to_return(status: 400)

    result = run(test, input)
    expect(result.result).to eq('pass')
  end
end
