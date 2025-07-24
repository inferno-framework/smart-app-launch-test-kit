module SMARTAppLaunch
  class ForwardValuesAttestationTest < Inferno::Test
    title 'Does not forward values passed back to its redirect URL'
    id :forward_values
    description %(
      The client application does not forward values passed back to its redirect URL.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@6'

    input :forward_values_correct,
          title: 'Does not forward values passed back to its redirect URL',
          description: %(
            I attest that the client application does not forward values passed back to its redirect URL.
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
    input :forward_values_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert forward_values_correct == 'true',
             'Client application forwards values passed back to its redirect URL.'
      pass forward_values_note if forward_values_note.present?
    end
  end
end
