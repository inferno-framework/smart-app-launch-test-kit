module SMARTAppLaunch
  class ScopesAttestationTest < Inferno::Test
    title 'Supports create, read, update, delete, and search scopes'
    id :scopes
    description %(
      The client application supports the following scopes:
      - Scope `c` for `create`
      - Scope `r` for `read`
      - Scope `u` for `update`
      - Scope `d` for `delete`
      - Scope `s` for `search`
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@120',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@121',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@122',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@124',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@125'
    input :scopes_correct,
          title: 'Supports create, read, update, delete, and search scopes',
          description: %(
            I attest that the client application supports the following scopes:
            - Scope `c` for `create`
            - Scope `r` for `read`
            - Scope `u` for `update`
            - Scope `d` for `delete`
            - Scope `s` for `search`
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
    input :scopes_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert scopes_correct == 'true',
             'Client application does not support create, read, update, delete and search scopes.'
      pass scopes_note if scopes_note.present?
    end
  end
end
