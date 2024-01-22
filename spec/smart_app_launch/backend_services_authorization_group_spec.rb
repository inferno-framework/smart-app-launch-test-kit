require_relative '../../lib/smart_app_launch/backend_services_authorization_group'
require_relative '../../lib/smart_app_launch/backend_services_authorization_request_builder'

RSpec.describe SMARTAppLaunch::BackendServicesAuthorizationGroup do
  let(:group) { Inferno::Repositories::TestGroups.new.find('backend_services_authorization') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_stu2') }
  let(:smart_token_url) { 'http://example.com/fhir' }
  let(:client_auth_encryption_method) { 'ES384' }
  let(:backend_services_requested_scope) { 'system/Patient.read' }
  let(:backend_services_client_id) { 'clientID' }
  let(:backend_services_jwks_kid) { nil }
  let(:exp) { 5.minutes.from_now }
  let(:jti) { SecureRandom.hex(32) }
  let(:request_builder) { BackendServicesAuthorizationRequestBuilder.new(builder_input) }
  let(:client_assertion) { create_client_assertion(client_assertion_input) }
  let(:body) { request_builder.authorization_request_query_values }
  let(:input) do
    {
      smart_token_url:,
      client_auth_encryption_method:,
      backend_services_requested_scope:,
      backend_services_client_id:
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
        name:,
        value:,
        type: runnable.config.input_type(name)
      )
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable)
  end

  describe '[Invalid grant_type] test' do
    let(:runnable) { group.tests[1] }

    it 'fails when token endpoint allows invalid grant_type' do
      stub_request(:post, smart_token_url)
        .with(body: hash_including(grant_type: 'not_a_grant_type'))
        .to_return(status: 200)

      result = run(runnable, input)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('Unexpected response status: expected 400, but received 200')
    end

    it 'passes when token endpoint requires valid grant_type' do
      stub_request(:post, smart_token_url)
        .with(body: hash_including(grant_type: 'not_a_grant_type'))
        .to_return(status: 400)

      result = run(runnable, input)

      expect(result.result).to eq('pass')
    end
  end

  describe '[Invalid client_assertion_type] test' do
    let(:runnable) { group.tests[2] }

    it 'fails when token endpoint allows invalid client_assertion_type' do
      stub_request(:post, smart_token_url)
        .with(body: hash_including(client_assertion_type: 'not_an_assertion_type'))
        .to_return(status: 200)

      result = run(runnable, input)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('Unexpected response status: expected 400, but received 200')
    end

    it 'passes when token endpoint requires valid client_assertion_type' do
      stub_request(:post, smart_token_url)
        .with(body: hash_including(client_assertion_type: 'not_an_assertion_type'))
        .to_return(status: 400)

      result = run(runnable, input)

      expect(result.result).to eq('pass')
    end
  end

  describe '[Invalid JWT token] test' do
    let(:runnable) { group.tests[3] }

    it 'fails when token endpoint allows invalid JWT token' do
      stub_request(:post, smart_token_url)
        .to_return(status: 200)

      result = run(runnable, input)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('Unexpected response status: expected 400, but received 200')
    end

    it 'passes when token endpoint requires valid JWT token' do
      stub_request(:post, smart_token_url)
        .to_return(status: 400)

      result = run(runnable, input)

      expect(result.result).to eq('pass')
    end
  end

  describe '[Authorization request succeeds when supplied correct information] test' do
    let(:runnable) { group.tests[4] }

    it 'fails if the access token request is rejected' do
      stub_request(:post, smart_token_url)
        .to_return(status: 400)

      result = run(runnable, input)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('Unexpected response status: expected 200, 201, but received 400')
    end

    it 'passes if the access token request is valid and authorized' do
      stub_request(:post, smart_token_url)
        .to_return(status: 200)

      result = run(runnable, input)

      expect(result.result).to eq('pass')
    end
  end

  describe '[Authorization request response body contains required information encoded in JSON] test' do
    let(:runnable) { group.tests[5] }
    let(:response_body) do
      {
        'access_token' => 'this_is_the_token',
        'token_type' => 'its_a_token',
        'expires_in' => 'a_couple_minutes',
        'scope' => 'system'
      }
    end

    it 'skips when no authentication response received' do
      result = run(runnable)

      expect(result.result).to eq('skip')
      expect(result.result_message).to eq('No authentication response received.')
    end

    it 'fails when authentication response is invalid JSON' do
      result = run(runnable, { authentication_response: '{/}' })

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('Invalid JSON. ')
    end

    it 'fails when authentication response does not contain access_token' do
      result = run(runnable, { authentication_response: '{"response_body":"post"}' })

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('Token response did not contain access_token as required')
    end

    it 'fails when access_token is present but does not contain required keys' do
      missing_key_auth_response = { 'access_token' => 'its_the_token' }
      result = run(runnable, { authentication_response: missing_key_auth_response.to_json })

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('Token response did not contain token_type as required')
    end

    it 'passes when access_token is present and contains the required keys' do
      result = run(runnable, { authentication_response: response_body.to_json })

      expect(result.result).to eq('pass')
    end
  end
end