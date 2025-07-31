module SMARTAppLaunch
  class StateParameterValidationAttestationTest < Inferno::Test
    title 'Validates the `state` value for any request sent to its redirect URL'
    id :state_param_validation
    description %(
      The client application validates the `state` value for any request sent to its redirect URL.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@4'

    input :state_param_validation_correct,
          title: 'Validates the `state` value for any request sent to its redirect URL',
          description: %(
            I attest that the client application validates the `state` value for any request sent to its redirect URL.
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
    input :state_param_validation_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert state_param_validation_correct == 'true',
             'Client application does not validate the `state` value for nay request sent to its redirect URL.'
      pass state_param_validation_note if state_param_validation_note.present?
    end
  end
end
