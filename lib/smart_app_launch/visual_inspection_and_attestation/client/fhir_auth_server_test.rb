module SMARTAppLaunch
  class FhirAuthorizationServerAttestationTest < Inferno::Test
    title 'Interact securely with a FHIR authorization server'
    id :fhir_authorization_server
    description %(
      Client applications securely interact with a FHIR authorization server by:
      - Authenticates the identify of the FHIR authorization server and establishes a secure link for exchange with TLS
      - Requests an access token with HTTP `POST` to the FHIR authorization server's token endpoint URL,
        using content-type `application/x-www-form-urlencoded`
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@230',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@234'

    input :tls_identification_and_exchange,
          title: 'Authenticates the identity of and exchanges with the FHIR authorization server with TLS',
          description: %(
            I attest that the client application authenticates the identity of the FHIR authorization server and
            establishes a secure link for exchange with TLS.
          ),
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Yes',
                value: 'true'
              },
              {
                label: 'No',
                value: 'false'
              }
            ]
          }
    input :tls_identification_and_exchange_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    input :fhir_auth_access_token,
          title: 'Requests an access token from the FHIR authorization server\'s token endpoint URL',
          description: %(
            I attest that the client application requests an access token with HTTP `POST` to the FHIR authorization
            server's token endpoint URL, using content-type `application/x-www-form-urlencoded`.
          ),
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Yes',
                value: 'true'
              },
              {
                label: 'No',
                value: 'false'
              }
            ]
          }
    input :fhir_auth_access_token_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert tls_identification_and_exchange == 'true',
             'Client application did not authenticate the identify of and exchanges with the FHIR authorization server
             with TLS.'
      pass tls_identification_and_exchange_note if tls_identification_and_exchange_note.present?

      assert fhir_auth_access_token == 'true',
             'Client application did not request an access token from the FHIR authorization server\'s token endpoint
             URL using content-type `application/x-www-form-urlencoded`.'
      pass fhir_auth_access_token_note if fhir_auth_access_token_note.present?
    end
  end
end