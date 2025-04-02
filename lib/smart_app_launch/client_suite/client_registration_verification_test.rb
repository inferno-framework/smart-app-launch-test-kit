require_relative '../tags'
require_relative '../urls'
require_relative '../endpoints/mock_smart_server'

module SMARTAppLaunch
  class SMARTClientRegistrationVerification < Inferno::Test
    include URLs

    id :smart_client_registration_verification
    title 'Verify SMART Registration'
    description %(
      During this test, Inferno will verify that the SMART registration details
      provided are conformant.
    )
    input :smart_jwk_set,
          title: 'SMART JSON Web Key Set (JWKS)',
          type: 'textarea',
          description: %(
            The SMART client's JSON Web Key Set including the key(s) Inferno will need to
            verify signatures on token requests made by the client. May be provided as either
            a publicly accessible url containing the JWKS, or the raw JWKS JSON.
          )
    input :client_id,
          title: 'Client Id',
          type: 'text',
          optional: true,
          description: %(
            If a particular client id is desired, put it here. Otherwise a
            default of the Inferno session id will be used.
          )

    output :client_id

    run do
      omit_if smart_jwk_set.blank?, # for re-use: mark the smart_jwk_set input as optional when importing to enable
        'Not configured for SMART authentication.'

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
