require_relative '../tags'
require_relative '../urls'
require_relative '../endpoints/mock_smart_server'
require_relative 'authentication_verification'
require_relative 'client_descriptions'
require_relative 'client_options'
require_relative 'token_request_verification'

module SMARTAppLaunch
  class SMARTClientTokenRequestAppLaunchConfidentialAsymmetricVerification < Inferno::Test
    include URLs
    include AuthenticationVerification
    include TokenRequestVerification

    id :smart_client_token_request_alca_verification
    title 'Verify SMART Token Requests'
    description %(
      Check that SMART token requests are conformant.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@64',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@68',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@69',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@70',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@233',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@237',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@238'

    input :client_id,
          title: 'Client Id',
          type: 'text',
          optional: false,
          locked: true,
          description: INPUT_CLIENT_ID_DESCRIPTION_LOCKED
    input :smart_jwk_set,
          title: 'JSON Web Key Set (JWKS)',
          type: 'textarea',
          locked: true,
          description: INPUT_CLIENT_JWKS_DESCRIPTION_LOCKED
    
    output :smart_tokens

    def client_suite_id
      return config.options[:endpoint_suite_id] if config.options[:endpoint_suite_id].present?

      SMARTAppLaunch::SMARTClientSTU22Suite.id
    end

    run do
      load_tagged_requests(TOKEN_TAG, SMART_TAG, AUTHORIZATION_CODE_TAG)
      skip_if requests.blank?, 'No SMART authorization code token requests made.'
      load_tagged_requests(TOKEN_TAG, SMART_TAG, REFRESH_TOKEN_TAG) # verify refresh_requests as well

      verify_token_requests(AUTHORIZATION_CODE_TAG, CONFIDENTIAL_ASYMMETRIC_TAG)

      assert messages.none? { |msg|
        msg[:type] == 'error'
      }, 'Invalid token requests received. See messages for details.'
    end
  end
end
