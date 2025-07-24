module SMARTAppLaunch
  class StateParameterAuthorizationCodeValidationAttestationTest < Inferno::Test
    title 'Performs validation on the value of the state parameter in authorization code requests'
    id :state_param_auth_code_validation
    description %(
      The client application performs validation on the value of the state parameter by:
      - Validating that the value of the state parameter sent by the server upon return to the redirect URL matches the
        value the client sent in the authorization request
      - Ensuring that the state value associated with the authorization request and response is securely tied to the
        user's current session
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@60',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@61'

    input :state_param_auth_code_validation_correct,
          title: 'Performs validation on the value of the state parameter in authorization code requests',
          description: %(
            I attest that the client application performs validation on the value of the state parameter by:
            - Validating that the value of the state parameter sent by the server upon return to the redirect URL
              matches the value the client sent in the authorization request
            - Ensuring that the state value associated with the authorization request and response is securely tied to
              the user's current session
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
    input :state_param_auth_code_validation_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert state_param_auth_code_validation_correct == 'true',
             'Client application does not perform validation on the value of the state parameter in authorization code requests.'
      pass state_param_auth_code_validation_note if state_param_auth_code_validation_note.present?
    end
  end
end
