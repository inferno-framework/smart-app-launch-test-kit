module SMARTAppLaunch
  class IdTokenUseAttestationTest < Inferno::Test
    title 'Uses ID tokens according to the IG'
    id :id_token_use
    description %(
      Client applications use ID tokens by following these steps:
      1. Examine the ID token for its “issuer” property
      2. Perform a `GET {issuer}/.well-known/openid-configuration`
      3. Fetch the server’s JSON Web Key by following the “jwks_uri” property [from the retrieved
         `openid-configuration`]
      4. Validate the token’s signature against the public key [retrieved from the ""jwks_uri"" location in the token's
         `openid-configuration`]
      5. Extract the fhirUser claim [from the verified token] and treat it as the URL of a FHIR resource"
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@218'

    input :id_token_steps,
          title: 'Uses ID tokens according to the IG',
          description: %(
            I attest that the client application uses ID tokens by following these steps:
            1. Examine the ID token for its “issuer” property
            2. Perform a `GET {issuer}/.well-known/openid-configuration`
            3. Fetch the server’s JSON Web Key by following the “jwks_uri” property [from the retrieved
              `openid-configuration`]
            4. Validate the token’s signature against the public key [retrieved from the ""jwks_uri"" location in the
               token's `openid-configuration`]
            5. Extract the fhirUser claim [from the verified token] and treat it as the URL of a FHIR resource"
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
    input :id_token_steps_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert id_token_steps == 'true',
             'Client application did not use ID tokens according to the IG.'
      pass id_token_steps_note if id_token_steps_note.present?
    end
  end
end