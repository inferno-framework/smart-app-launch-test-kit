module SMARTAppLaunch
  class IDTokenScopesAttestationTest < Inferno::Test
    title 'Receives an id_token with the access tokens when the `openid` and `fhirUser` scopes are granted'
    id :id_token_scopes
    description %(
      The client application receives an id_token with the access tokens when the `openid` and
      `fhirUser` scopes are requested and granted.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@47',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@50'

    input :id_token_scopes_correct,
          title: 'Receives an id_token with the access tokens when the `openid` and `fhirUser` scopes are granted',
          description: %(
            I attest that the client application receives an id_token with the access tokens when the `openid` and
            `fhirUser` scopes are requested and granted.
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
    input :id_token_scopes_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert id_token_scopes_correct == 'true',
             'Client application does not receive an id_token with the access tokens when the `openid` and `fhirUser`
              scopes are granted.'
      pass id_token_scopes_note if id_token_scopes_note.present?
    end
  end
end
