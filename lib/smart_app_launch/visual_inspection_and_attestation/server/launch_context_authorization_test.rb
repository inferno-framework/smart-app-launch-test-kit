module SMARTAppLaunch
  class LaunchContextAuthorizationAttestationTest < Inferno::Test
    title 'Includes launch context parameters and context data in launch context authorization'
    id :launch_context_authorization
    description %(
      Servers adhere to the following guidelines for launch context authorization:
      - Includes any context data the app requested and any (potentially) unsolicited context data the EHR may decide to
        communicate in the token response
      - Includes any launch context parameters and come alongside the the access token which appear as JSON parameters
        in the token response
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@168',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@169'

    input :launch_context,
          title: 'Includes launch context parameters and context data in launch context authorization',
          description: %(
            I attest that the server adheres to the following guidelines for launch context authorization:
            - Includes any context data the app requested and any (potentially) unsolicited context data the EHR may
              decide to communicate in the token response
            - Includes any launch context parameters and come alongside the the access token which appear as JSON
              parameters in the token response
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
    input :launch_context_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert launch_context == 'true',
             'Server did not include launch context parameters and context data in launch context authorization.'
      pass launch_context_note if launch_context_note.present?
    end
  end
end