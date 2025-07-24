module SMARTAppLaunch
  class UntrustedUserInputsAttestationTest < Inferno::Test
    title 'Does not execute untrusted user-supplied inputs as code'
    id :untrusted_user_inputs
    description %(
      The client application does not execute untrusted user-supplied inputs as code.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@5'

    input :untrusted_user_inputs_correct,
          title: 'Does not execute untrusted user-supplied inputs as code',
          description: %(
            I attest that the client application does not execute untrusted user-supplied inputs as code.
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
    input :untrusted_user_inputs_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert untrusted_user_inputs_correct == 'true',
             'Client application executed untrusted user-supplied inputs as code.'
      pass untrusted_user_inputs_note if untrusted_user_inputs_note.present?
    end
  end
end
