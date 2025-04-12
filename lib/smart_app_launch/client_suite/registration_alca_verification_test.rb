require_relative '../tags'
require_relative '../endpoints/mock_smart_server'
require_relative 'client_options'
require_relative 'registration_verification'
require_relative 'client_descriptions'

module SMARTAppLaunch
  class SMARTClientRegistrationAppLaunchConfidentialAsymmetricVerification < Inferno::Test
    include RegistrationVerification

    id :smart_client_registration_alca_verification
    title 'Verify SMART App Launch Confidential Asymmetric Client Registration'
    description %(
      During this test, Inferno will verify that the registration details
      provided for a [SMART App Launch](https://hl7.org/fhir/smart-app-launch/STU2.2/app-launch.html)
      confidential client using [asymmetric authentication](https://hl7.org/fhir/smart-app-launch/STU2.2/client-confidential-asymmetric.html) 
      are conformant.
    )
    
    input :client_id,
          title: 'Client Id',
          type: 'text',
          optional: true,
          description: INPUT_CLIENT_ID_DESCRIPTION
    input :smart_launch_urls,
          title: 'SMART App Launch URL(s)',
          type: 'textarea',
          optional: true,
          description: INPUT_SMART_LAUNCH_URLS_DESCRIPTION
    input :smart_redirect_uris,
          title: 'SMART App Launch Redirect URI(s)',
          type: 'textarea',
          description: INPUT_SMART_REDIRECT_URIS_DESCRIPTION
    input :smart_jwk_set,
          title: 'SMART Confidential Asymmetric JSON Web Key Set (JWKS)',
          type: 'textarea',
          description: INPUT_CLIENT_JWKS_DESCRIPTION
    
    output :client_id
    output :smart_launch_urls # normalized
    output :smart_redirect_uris # normalized

    run do
      if client_id.blank?
        client_id = test_session_id
        output(client_id:)
      end

      verify_registered_launch_urls(smart_launch_urls)
      verify_registered_redirect_uris(smart_redirect_uris)
      verify_registered_jwks(smart_jwk_set)

      assert messages.none? { |msg| msg[:type] == 'error' },
             'Invalid registration details provided. See messages for details'
    end    
  end
end
