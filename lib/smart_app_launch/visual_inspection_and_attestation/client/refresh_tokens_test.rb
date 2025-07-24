module SMARTAppLaunch
  class RefreshTokensAttestationTest < Inferno::Test
    title 'Contains required parameters when requesting a new access token using a refresh token'
    id :refresh_tokens
    description %(
      When requesting a new access token using a refresh token, the client application requires the following:
      - `refresh_token` parameter that contains the refresh token from a prior authorization response
      - `scope` parameter that is a strict sub-set of the scopes granted in the original launch
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@106',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@108'

    input :refresh_tokens_correct,
          title: 'Contains required parameters when requesting a new access token using a refresh token',
          description: %(
            I attest that when requesting a new access token using a refresh token, the client application
            requires the following:
            - `refresh_token` parameter that contains the refresh token from a prior authorization response
            - `scope` parameter that is a strict sub-set of the scopes granted in the original launch
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
    input :refresh_tokens_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert refresh_tokens_correct == 'true',
             'Client application does not contain required parameters when requesting a new access token using a
             refresh token.'
      pass refresh_tokens_note if refresh_tokens_note.present?
    end
  end
end
