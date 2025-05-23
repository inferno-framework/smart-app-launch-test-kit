require_relative '../tags'
require_relative '../endpoints/mock_smart_server'
require_relative 'client_options'
require_relative 'registration_verification'
require_relative 'client_descriptions'

module SMARTAppLaunch
  class SMARTClientRegistrationAppLaunchConfidentialSymmetricVerification < Inferno::Test
    include RegistrationVerification

    id :smart_client_registration_alcs_verification
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@20',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@21',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@23'
    title 'Verify SMART App Launch Confidential Symmetric Client Registration'
    description %(
      During this test, Inferno will verify that the registration details
      provided for a [SMART App Launch](https://hl7.org/fhir/smart-app-launch/STU2.2/app-launch.html)
      confidential client using [symmetric authentication](https://hl7.org/fhir/smart-app-launch/STU2.2/client-confidential-symmetric.html) 
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
    input :smart_client_secret,
          title: 'SMART Confidential Symmetric Client Secret',
          type: 'text',
          description: INPUT_CLIENT_SECRET_DESCRIPTION
    
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

      assert messages.none? { |msg| msg[:type] == 'error' },
             'Invalid registration details provided. See messages for details'
    end    
  end
end
