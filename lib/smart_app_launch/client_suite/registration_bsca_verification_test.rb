require_relative '../tags'
require_relative '../endpoints/mock_smart_server'

module SMARTAppLaunch
  class SMARTClientBackendServicesRegistrationVerification < Inferno::Test

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

      jwks_warnings = []
      parsed_smart_jwk_set = MockSMARTServer.jwk_set(smart_jwk_set, jwks_warnings)
      jwks_warnings.each { |warning| add_message('warning', warning) }

      assert parsed_smart_jwk_set.length.positive?, 'JWKS content does not include any valid keys.'

      # TODO: add key-specific verification per end of https://build.fhir.org/ig/HL7/smart-app-launch/client-confidential-asymmetric.html#registering-a-client-communicating-public-keys

      assert messages.none? { |msg| msg[:type] == 'error' }, 'Invalid key set provided. See messages for details'
    end
  end
end
