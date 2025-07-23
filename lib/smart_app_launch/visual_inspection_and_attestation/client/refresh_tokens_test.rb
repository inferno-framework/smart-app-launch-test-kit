module SMARTAppLaunch
  class RefreshTokensAttestationTest < Inferno::Test
    title 'Contains required parameters when requesting a new access token using a refresh token'
    id :refresh_tokens
    description %(
      When requesting a new access token using a refresh token, client applications require the following:
      - `refresh_token` parameter that contains the refresh token from a prior authorization response
      - `scope` parameter that is a strict sub-set of the scopes granted in the original launch
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@106',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@108'

    input :refresh_token_request_params,
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
    input :refresh_token_request_params_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert refresh_token_request_params == 'true',
             'Client application did not have required parameters when requesting a new access token using a refresh token.'
      pass refresh_token_request_params_note if refresh_token_request_params_note.present?
    end
  end
end