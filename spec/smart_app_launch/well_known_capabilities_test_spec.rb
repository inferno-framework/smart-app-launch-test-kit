require_relative '../../lib/smart_app_launch/well_known_capabilities_stu1_test'
require_relative '../../lib/smart_app_launch/well_known_capabilities_stu2_test'

RSpec.describe "Well-Known Tests" do
  let(:test_v1) { Inferno::Repositories::Tests.new.find('well_known_capabilities_stu1') }
  let(:test_v2) { Inferno::Repositories::Tests.new.find('well_known_capabilities_stu2') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart') }
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
    Inferno::TestRunner.new(test_session: test_session, test_run: test_run).run(runnable)
  end

  shared_examples 'well-known tests' do
    it 'passes when the well-known configuration contains all required fields' do
      result = run(runnable, well_known_configuration: valid_config.to_json)

      expect(result.result).to eq('pass')
    end

    it 'fails if a required field is missing' do
      ['authorization_endpoint', 'token_endpoint', 'capabilities'].each do |field|
        config = valid_config.reject { |key, _| key == field }
        result = run(runnable, well_known_configuration: config.to_json)

        expect(result.result).to eq('fail')
        expect(result.result_message).to eq("Well-known configuration does not include `#{field}`")
      end
    end

    it 'fails if a required field is blank' do
      ['authorization_endpoint', 'token_endpoint', 'capabilities'].each do |field|
        config = valid_config.dup
        config[field] = ''
        result = run(runnable, well_known_configuration: config.to_json)

        expect(result.result).to eq('fail')
        expect(result.result_message).to eq("Well-known configuration field `#{field}` is blank")
      end
    end

    it 'fails if a required field is the wrong type' do
      ['authorization_endpoint', 'token_endpoint'].each do |field|
        config = valid_config.dup
        config[field] = 1
        result = run(runnable, well_known_configuration: config.to_json)

        expect(result.result).to eq('fail')
        expect(result.result_message).to match(/must be type: string/)
      end

      config = valid_config.dup
      config['capabilities'] = '1'
      result = run(runnable, well_known_configuration: config.to_json)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/must be type: array/)
    end

    it 'fails if the capabilities field contains a non-string entry' do
      config = valid_config.dup
      config['capabilities'].concat [1, nil]
      result = run(runnable, well_known_configuration: config.to_json)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/must be an array of strings/)
      expect(result.result_message).to match(/`1`/)
      expect(result.result_message).to match(/`nil`/)
    end
  end

  describe SMARTAppLaunch::WellKnownCapabilitiesSTU1Test do
    it_behaves_like 'well-known tests' do
      let(:runnable) { test_v1 }
      let(:required_fields) { ['authorization_endpoint', 'token_endpoint', 'capabilities'] }
      let(:valid_config) { well_known_config.slice(*required_fields) }
    end
  end

  describe SMARTAppLaunch::WellKnownCapabilitiesSTU2Test do
    let(:required_fields) { ['authorization_endpoint', 'token_endpoint', 'capabilities', 'issuer', 'jwks_uri', 'grant_types_supported', 'code_challenge_methods_supported'] }
    let(:runnable) { test_v2 }
    let(:valid_config) { well_known_config.slice(*required_fields) }

    it_behaves_like 'well-known tests'

    it 'fails if `issuer` is missing while `sso-openid-connect` is listed as a capability' do
      valid_config.delete('issuer')
      result = run(runnable, well_known_configuration: valid_config.to_json)
      expect(result.result).to eq('fail')
      expect(result.result_message).to match('Well-known `issuer` field must be a string and present when server capabilities includes `sso-openid-connect`')
    end

    it 'fails if `jwks_uri` is missing while `sso-openid-connect` is listed as a capability' do
      valid_config.delete('jwks_uri')
      result = run(runnable, well_known_configuration: valid_config.to_json)
      expect(result.result).to eq('fail')
      expect(result.result_message).to match('Well-known `jwks_uri` field must be a string and present when server capabilites includes `sso-openid-coneect`')
    end

    it 'warns if `issuer` is present while `sso-openid-connect` is not listed as a capability' do
      valid_config['capabilities'].reject! { |capability| capability == 'sso-openid-connect' }
      result = run(runnable, well_known_configuration: valid_config.to_json)
      expect(result.result).to eq('pass')
      warning_messages = Inferno::Repositories::Messages.new.messages_for_result(result.id).filter { |message| message.type == 'warning' }
      expect(warning_messages.any? { |wm| wm.message.include? 'Well-known `issuer` is omitted when server capabilites does not include `sso-openid-connect`'}).to be_truthy
    end
  end
end
