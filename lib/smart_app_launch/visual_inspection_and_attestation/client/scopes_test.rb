module SMARTAppLaunch
  class ScopesAttestationTest < Inferno::Test
    title 'Supports create, read, update, delete, and search scopes'
    id :scopes
    description %(
      Client application supports the following scopes:
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
    input :scope_support,
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
    input :scope_support_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert scope_support == 'true',
             'Client application did not support create, read, update, delete and search scopes.'
      pass scope_support_note if scope_support_note.present?
    end
  end
end