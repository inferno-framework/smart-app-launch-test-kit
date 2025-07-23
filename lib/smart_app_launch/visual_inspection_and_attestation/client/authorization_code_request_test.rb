module SMARTAppLaunch
  class AuthorizationCodeRequestAttestationTest < Inferno::Test
    title 'Follows guidelines for sending authorization code requests'
    id :authorization_code_request
    description %(
      Client applications follow guidelines for sending requests for authorization codes by:
      - Omitting the `launch` parameter in the `Standalone Launch` flow
      - Requires the `state` parameter for cross-site request forgery or session fixation attack prevention
      - Uses an unpredictable value for the `state` parameter with at least 122 bits of entropy or random uuid
      - Receives an id_token with the access tokens when the `openid` and `fhirUser` scopes are requested and granted
      - Uses the HTTP GET or HTTP POST method
      - Serializes the request parameters for HTTP GET method requests using URI Query String Serialization
      - Serializes the request parameters for HTTP POST method requests using Form Serialization and
        application/x-www-form-urlencoded content type
      - Validates the value of the state parameter
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@36',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@39',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@40',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@47',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@50',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@51',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@52'

    input :launch_param_omit,
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

    input :requires_state_params,
          title: 'Requires the `state` parameter and uses an unpredictable value that is then validated',
          description: %(
            I attest that the client application requires the `state` parameter and uses an unpredictable value that is
            validated.
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
    input :requires_state_params_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    input :id_token_scopes,
          title: 'Receives an id_token with the access tokens when the `openid` and `fhirUser` scopes are granted',
          description: %(
            I attest that the client application receives an id_token with the access tokens when the `openid` and
            `fhirUser` scopes are requested and granted.
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
    input :id_token_scopes_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    input :http_post_get,
          title: 'Uses the HTTP GET or HTTP POST method and serializes the requests appropriately',
          description: %(
            I attest that the client application uses the HTTP GET or HTTP POST method and serializes the HTTP GET
            method requests using URI Query String Serialization and the HTTP POST method requests using Form
            Serialization and application/x-www-form-urlencoded content type.
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
    input :http_post_get_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert launch_param_omit == 'true',
             'Client application did not omit the `launch` parameter in the `Standalone Launch` flow.'
      pass launch_param_omit_note if launch_param_omit_note.present?

      assert requires_state_params == 'true',
             'Client application did not require the `state` parameter, use an unpredictable value and validate.'
      pass requires_state_params_note if requires_state_params_note.present?

      assert id_token_scopes == 'true',
             'Client application did not receive an id_token with the access tokens when the `openid` and `fhirUser`
              scopes were granted.'
      pass id_token_scopes_note if id_token_scopes_note.present?

      assert http_post_get == 'true',
             'Client application did not use HTTP GET or HTTP POST methods with appropriate request serialization.'
      pass http_post_get_note if http_post_get_note.present?
    end
  end
end