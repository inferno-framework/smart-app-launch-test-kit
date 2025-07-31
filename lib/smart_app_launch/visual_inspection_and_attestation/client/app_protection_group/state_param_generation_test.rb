module SMARTAppLaunch
  class StateParameterGenerationAttestationTest < Inferno::Test
    title 'Generates an unpredictable `state` parameter value for each use session'
    id :state_param_generation
    description %(
      The client application generates an unpredictable `state` parameter for each use session.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@2'

    input :state_param_generation_correct,
          title: 'Generates an unpredictable `state` parameter value for each use session',
          description: %(
            I attest that the client application generates an unpredictable `state` parameter for each use session.
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
    input :state_param_generation_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert state_param_generation_correct == 'true',
             'Client application does not generate an unpredictable `state` parameter value for each use session.'
      pass state_param_generation_note if state_param_generation_note.present?
    end
  end
end
