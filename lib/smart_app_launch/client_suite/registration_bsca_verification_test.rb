require_relative '../tags'
require_relative '../endpoints/mock_smart_server'
require_relative 'registration_verification'

module SMARTAppLaunch
  class SMARTClientBackendServicesRegistrationVerification < Inferno::Test
    include RegistrationVerification

    id :smart_client_registration_bsca_verification
    title 'Verify SMART Backend Services Confidential Asymmetric Client Registration'
    description %(
      During this test, Inferno will verify that the registration details
      provided for a [SMART Backend Services](https://hl7.org/fhir/smart-app-launch/STU2.2/backend-services.html)
      client using [asymmetric authentication](https://hl7.org/fhir/smart-app-launch/STU2.2/client-confidential-asymmetric.html)
      are valid.
    )
    input :client_id,
          title: 'Client Id',
          type: 'text',
          optional: true,
          description: INPUT_CLIENT_ID_DESCRIPTION
    input :smart_jwk_set,
          title: 'SMART Confidential Asymmetric JSON Web Key Set (JWKS)',
          type: 'textarea',
          description: INPUT_CLIENT_JWKS_DESCRIPTION

    output :client_id

    run do
      if client_id.blank?
        client_id = test_session_id
        output(client_id:)
      end

      verify_registered_jwks(smart_jwk_set)

      assert messages.none? { |msg| msg[:type] == 'error' }, 'Invalid key set provided. See messages for details'
    end
  end
end
