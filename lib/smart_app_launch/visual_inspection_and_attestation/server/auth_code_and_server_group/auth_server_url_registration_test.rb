module SMARTAppLaunch
  class AuthorizationServerURLRegistrationAttestationTest < Inferno::Test
    title 'Registers URLs with the authorization server'
    id :auth_server_url_registration
    description %(
      The server registers complete URLs of all apps approved for use by users with the EHR authorization server.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@18'

    input :auth_server_url_registration_correct,
          title: 'Registers URLs with the authorization server',
          description: %(
            I attest that the server registers complete URLs of all apps approved for use by users with the EHR
            authorization server.
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
    input :auth_server_url_registration_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert auth_server_url_registration_correct == 'true',
             'Server does not register URLs with the authorization server.'
      pass auth_server_url_registration_note if auth_server_url_registration_note.present?
    end
  end
end