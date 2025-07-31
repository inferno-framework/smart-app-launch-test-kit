module SMARTAppLaunch
  class AccessTokenScopeAttestationTest < Inferno::Test
    title 'Complies with requirements for scopes in access token requests'
    id :access_token_scope
    description %(
      The server complies with requirements for scopes in access token requests:
      - Pre-authorizes the client/associates the client with the authority to access certain data
      - Applies the set of scopes received in the access token request from the client as additional access restrictions
        following the SMART Scopes syntax
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@240',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@241'

    input :access_token_scope_correct,
          title: 'Complies with requirements for scopes in access token requests',
          description: %(
            I attest that the server complies with requirements for scopes in access token requests:
            - Pre-authorizes the client/associates the client with the authority to access certain data
            - Applies the set of scopes received in the access token request from the client as additional access
              restrictions following the SMART Scopes syntax
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
    input :access_token_scope_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert access_token_scope_correct == 'true',
             'Server does not comply with requirements for scopes in access token requests.'
      pass access_token_scope_note if access_token_scope_note.present?
    end
  end
end
