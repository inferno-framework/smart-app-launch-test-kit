module SMARTAppLaunch
  class FhirAuthorizationServerAccessTokenAttestationTest < Inferno::Test
    title 'Requests an access token with POST to the FHIR authorization server'
    id :fhir_auth_server_access_token
    description %(
      The client application requests an access token with HTTP `POST` to the FHIR authorization server's token endpoint
      URL, using content-type `application/x-www-form-urlencoded.`
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@234'

    input :fhir_auth_server_access_token_correct,
          title: 'Requests an access token with POST to the FHIR authorization server',
          description: %(
            I attest that the client application requests an access token with HTTP `POST` to the FHIR authorization
            server's token endpoint URL, using content-type `application/x-www-form-urlencoded.`
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
    input :fhir_auth_server_access_token_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert fhir_auth_server_access_token_correct == 'true',
             'Client application does not request an access token from the FHIR authorization server\'s token endpoint
             URL using content-type `application/x-www-form-urlencoded`.'
      pass fhir_auth_server_access_token_note if fhir_auth_server_access_token_note.present?
    end
  end
end
