module SMARTAppLaunch
  class LaunchScopeAttestationTest < Inferno::Test
    title 'Includes resource types requested by launch scope in the `fhirContext`'
    id :launch_scope
    description %(
      The servers includes resource types requested by a launch scope in the `fhirContext` array except Patient and
      Encounter resource types unless they include a `role` other than "launch".
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@177'

    input :launch_scope_correct,
          title: 'Includes resource types requested by launch scope in the `fhirContext`',
          description: %(
            I attest that the server includes resource types requested by a launch scope in the `fhirContext` array
            except Patient and Encounter resource types unless they include a `role` other than "launch".
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
    input :launch_scope_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert launch_scope_correct == 'true',
             'Server does not include resource types requested by launch scope in the `fhirContext`.'
      pass launch_scope_note if launch_scope_note.present?
    end
  end
end