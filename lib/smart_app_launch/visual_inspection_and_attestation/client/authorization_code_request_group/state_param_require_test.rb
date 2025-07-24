module SMARTAppLaunch
  class StateParameterRequireAttestationTest < Inferno::Test
    title 'Requires the `state` parameter and uses an unpredictable value that is then validated'
    id :state_param_require
    description %(
      The client application requires the `state` parameter and uses an unpredictable value that is
      validated.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@39',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@40'

    input :state_param_require_correct,
          title: 'Requires the `state` parameter and uses an unpredictable value that is then validated',
          description: %(
            I attest that the client application requires the `state` parameter and uses an unpredictable value that is
            validated.
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
    input :state_param_require_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert state_param_require_correct == 'true',
             'Client application does not require the `state` parameter, use an unpredictable value or validate.'
      pass state_param_require_note if state_param_require_note.present?
    end
  end
end
