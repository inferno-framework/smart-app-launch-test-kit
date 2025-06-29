require_relative 'backend_services_authorization_request_builder'

module SMARTAppLaunch
  class BackendServicesAuthorizationResponseBodyTest < Inferno::Test
    id :smart_backend_services_auth_response_body
    title 'Authorization request response body contains required information encoded in JSON'
    description <<~DESCRIPTION
      The [SMART App Launch 2.0.0 IG specification for Backend Services](https://hl7.org/fhir/smart-app-launch/STU2/backend-services.html#issue-access-token)
      states The access token response SHALL be a JSON object with the following properties:

      | Token Property | Required? | Description |
      | --- | --- | --- |
      | `access_token` | required | The access token issued by the authorization server. |
      | `token_type` | required | Fixed value: `bearer`. |
      | `expires_in` | required | The lifetime in seconds of the access token. The recommended value is `300`, for a five-minute token lifetime. |
      | `scope` | required | Scope of access authorized. Note that this can be different from the scopes requested by the app. |
    DESCRIPTION

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@254',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@255',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@256',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@258'

    input :authentication_response
    input :smart_auth_info,
          type: :auth_info,
          options: {
            mode: 'auth',
            components: [
              {
                name: :auth_type,
                default: 'backend_services',
                locked: 'true'
              }
            ]
          }
    output :bearer_token, :smart_auth_info, :received_scopes

    run do
      skip_if authentication_response.blank?, 'No authentication response received.'

      assert_valid_json(authentication_response)
      response_body = JSON.parse(authentication_response)

      access_token = response_body['access_token']
      received_scopes = response_body['scope']
      expires_in = response_body['expires_in']

      assert access_token.present?, 'Token response did not contain access_token as required'

      smart_auth_info.access_token = access_token
      smart_auth_info.expires_in = expires_in

      output bearer_token: access_token, smart_auth_info: smart_auth_info, received_scopes: received_scopes

      required_keys = ['token_type', 'expires_in', 'scope']

      required_keys.each do |key|
        assert response_body[key].present?, "Token response did not contain #{key} as required"
        if key == 'token_type'
          assert response_body[key].casecmp('bearer').zero?, '`token_type` must be `bearer`'
        elsif key == 'expires_in'
          assert response_body[key].is_a?(Numeric),
                 "Expected expires_in to be a Numeric, but found #{response_body[key].class.name}"
        end
      end
    end
  end
end
