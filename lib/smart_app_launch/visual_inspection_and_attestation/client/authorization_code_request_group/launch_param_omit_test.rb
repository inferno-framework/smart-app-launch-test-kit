module SMARTAppLaunch
  class LaunchParameterOmitAttestationTest < Inferno::Test
    title 'Omits the `launch` parameter in the `Standalone Launch` flow'
    id :launch_param_omit
    description %(
      The client application omits the `launch` parameter in the `Standalone Launch` flow.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@36'

    input :launch_param_omit_correct,
          title: 'Omits the `launch` parameter in the `Standalone Launch` flow',
          description: %(
            I attest that the client application omits the `launch` parameter in the `Standalone Launch` flow.
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
    input :launch_param_omit_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert launch_param_omit_correct == 'true',
             'Client application does not omit the `launch` parameter in the `Standalone Launch` flow.'
      pass launch_param_omit_note if launch_param_omit_note.present?
    end
  end
end
