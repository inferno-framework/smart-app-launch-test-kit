module SMARTAppLaunch
  class RefreshAccessTokensAttestationTest < Inferno::Test
    title 'Complies with requirements for refresh access tokens'
    id :refresh_access_tokens
    description %(
      The server complies with requirements for refresh access tokens:
      - Provides an app with "online-access" and can get new access tokens as long as the end-user remains online
      - Provides an app with "offline access" and can get new access tokens without the user being interactively
        engaged
      - Bounds refresh tokens to the same `client_id` and contains the same or a subset of the claims authorized for the
        access token with which it was associated
      - Ensures refresh tokens contain the same or a subset of the claims authorized for the access token with which it
        is associated
      - Responds to requests for a new access token using a refresh token with a `scope` parameter value that can be
        different from the scopes requested by the app
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@100',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@101',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@103',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@104',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@115'

    input :refresh_access_tokens_correct,
          title: 'Complies with requirements for refresh access tokens',
          description: %(
            I attest that the server complies with requirements for refresh access tokens:
            - Provides an app with "online-access" and can get new access tokens as long as the end-user remains online
            - Provides an app with "offline access" and can get new access tokens without the user being interactively
              engaged
            - Bounds refresh tokens to the same `client_id` and contains the same or a subset of the claims authorized
              for the access token with which it was associated
            - Ensures refresh tokens contain the same or a subset of the claims authorized for the access token with
              which it is associated
            - Responds to requests for a new access token using a refresh token with a `scope` parameter value that can
              be different from the scopes requested by the app
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
    input :refresh_access_tokens_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert refresh_access_tokens_correct == 'true',
             'Server does not comply with requirements for refresh access tokens.'
      pass refresh_access_tokens_note if refresh_access_tokens_note.present?
    end
  end
end