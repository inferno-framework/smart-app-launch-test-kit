require_relative '../../lib/smart_app_launch/discovery_stu1_group'

RSpec.describe SMARTAppLaunch::DiscoverySTU1Group do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('smart') }
  let(:group) { Inferno::Repositories::TestGroups.new.find('smart_discovery_stu1') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart') }
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

  describe 'capability statement test' do
    let(:runnable) { group.tests[2] }
    let(:minimal_capabilities) { FHIR::CapabilityStatement.new(fhirVersion: '4.0.1') }
    let(:full_extensions) do
      [
        {
          url: 'authorize',
          valueUri: "#{url}/authorize"
        },
        {
          url: 'introspect',
          valueUri: "#{url}/introspect"
        },
        {
          url: 'manage',
          valueUri: "#{url}/manage"
        },
        {
          url: 'register',
          valueUri: "#{url}/register"
        },
        {
          url: 'revoke',
          valueUri: "#{url}/revoke"
        },
        {
          url: 'token',
          valueUri: "#{url}/token"
        }
      ]
    end
    let(:full_capabilities) { capabilities_with_smart(full_extensions) }

    def capabilities_with_smart(extensions)
      FHIR::CapabilityStatement.new(
        fhirVersion: '4.0.1',
        rest: [
          security: {
            service: [
              {
                coding: [
                  {
                    system: 'http://hl7.org/fhir/restful-security-service',
                    code: 'SMART-on-FHIR'
                  }
                ]
              }
            ],
            extension: [
              {
                url: 'http://fhir-registry.smarthealthit.org/StructureDefinition/oauth-uris',
                extension: extensions
              }
            ]
          }
        ]
      )
    end

    it 'passes when all required extensions are present' do
      stub_request(:get, "#{url}/metadata")
        .to_return(status: 200, body: full_capabilities.to_json)

      result = run(runnable, url: url)

      expect(result.result).to eq('pass')
    end

    it 'fails when a non-200 response is received' do
      stub_request(:get, "#{url}/metadata")
        .to_return(status: 500, body: minimal_capabilities.to_json)

      result = run(runnable, url: url)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/Bad response status/)
    end

    it 'fails when no SMART extensions are returned' do
      stub_request(:get, "#{url}/metadata")
        .to_return(status: 200, body: minimal_capabilities.to_json)

      result = run(runnable, url: url)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('No SMART extensions found in CapabilityStatement')
    end

    it 'fails when no authorize extension is returned' do
      extensions = full_extensions.reject { |extension| extension[:url] == 'authorize' }
      stub_request(:get, "#{url}/metadata")
        .to_return(status: 200, body: capabilities_with_smart(extensions).to_json)

      result = run(runnable, url: url)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('No `authorize` extension found')
    end

    it 'fails when no token extension is returned' do
      extensions = full_extensions.reject { |extension| extension[:url] == 'token' }
      stub_request(:get, "#{url}/metadata")
        .to_return(status: 200, body: capabilities_with_smart(extensions).to_json)

      result = run(runnable, url: url)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('No `token` extension found')
    end
  end

  describe 'endpoints match test' do
    let(:runnable) { group.tests[3] }
    let(:full_inputs) do
      [
        'authorization',
        'token',
        'introspection',
        'management',
        'registration',
        'revocation'
      ].each_with_object({}) do |type, inputs|
        inputs["well_known_#{type}_url".to_sym] = "#{type.upcase}_URL"
        inputs["capability_#{type}_url".to_sym] = "#{type.upcase}_URL"
      end
    end

    it 'passes if all urls match' do
      result = run(runnable, full_inputs)

      expect(result.result).to eq('pass')
    end

    it 'fails if a url does not match' do
      full_inputs[:well_known_introspection_url] = 'abc'
      result = run(runnable, full_inputs)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/The following urls do not match:\n- Introspection/)
      expect(result.result_message).to include(full_inputs[:well_known_introspection_url])
      expect(result.result_message).to include(full_inputs[:capability_introspection_url])
    end
  end
end
