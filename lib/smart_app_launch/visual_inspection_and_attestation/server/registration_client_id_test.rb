module SMARTAppLaunch
  class RegistrationClientIDAttestationTest < Inferno::Test
    title 'Communicates a `client_id` to the app during registration'
    id :registration_client_id
    description %(
      Servers confirm the app's registration parameters and communicate a `client_id` to the app.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@24'

    input :client_id,
          title: 'Communicates a `client_id` to the app during registration',
          description: %(
            I attest that the server confirms the app's registration parameters and communicates a `client_id` to the
            app.
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
    input :client_id_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert client_id == 'true',
             'Server did not communicate a `client_id` to the app during registration.'
      pass client_id_note if client_id_note.present?
    end
  end
end
