module SMARTAppLaunch
  class BackendServicesScopesAttestationTest < Inferno::Test
    title 'Follows procedures for scopes in access token requests'
    id :backend_services_scopes
    description %(
      Servers adhere to the following procedures for scopes in access token requests:
      - Pre-authorizes the client/associates the client with the authority to access certain data
      - Applies the set of scopes received in the access token request from the client as additional access restrictions
        following the SMART Scopes syntax
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@240',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@241'

    input :access_token_scopes,
          title: 'Follows procedures for scopes in access token requests',
          description: %(
            I attest that the server adheres to the following procedures for scopes in access token requests:
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
    input :access_token_scopes_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert access_token_scopes == 'true',
             'Server did not follow procedures for scopes in access token requests.'
      pass access_token_scopes_note if access_token_scopes_note.present?
    end
  end
end
