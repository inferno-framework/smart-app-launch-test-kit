require_relative '../tags'
require_relative '../urls'
require_relative '../endpoints/mock_smart_server'
require_relative 'authentication_verification'
require_relative 'client_descriptions'
require_relative 'client_options'
require_relative 'token_request_verification'


module SMARTAppLaunch
  class SMARTClientTokenRequestBackendServicesConfidentialAsymmetricVerification < Inferno::Test
    include URLs
    include AuthenticationVerification
    include TokenRequestVerification

    id :smart_client_token_request_bsca_verification
    title 'Verify SMART Token Requests'
    description %(
        Check that SMART token requests are conformant.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@229',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@230',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@233',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@234',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@235',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@236',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@237',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@238',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@267'

    input :client_id,
          title: 'Client Id',
          type: 'text',
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
      load_tagged_requests(TOKEN_TAG, SMART_TAG, CLIENT_CREDENTIALS_TAG)
      skip_if requests.blank?, 'No SMART token requests made.'
      load_tagged_requests(TOKEN_TAG, SMART_TAG, REFRESH_TOKEN_TAG) # verify refresh_requests as well (shouldn't be any)

      verify_token_requests(CLIENT_CREDENTIALS_TAG, CONFIDENTIAL_ASYMMETRIC_TAG)

      assert messages.none? { |msg|
        msg[:type] == 'error'
      }, 'Invalid token requests received. See messages for details.'
    end
  end
end
