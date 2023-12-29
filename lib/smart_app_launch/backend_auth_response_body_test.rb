require_relative 'authorization_request_builder'

module SMARTAppLaunch 
  class BackendServicesAuthorizationResponseBodyTest < Inferno::Test 
    id :smart_backend_services_auth_response_body
    title 'Authorization request response body contains required information encoded in JSON'
    description <<~DESCRIPTION
      The access token response SHALL be a JSON object with the following properties:

      | Token Property | Required? | Description |
      | --- | --- | --- |
      | access_token | required | The access token issued by the authorization server. |
      | token_type | required | Fixed value: bearer. |
      | expires_in | required | The lifetime in seconds of the access token. The recommended value is 300, for a five-minute token lifetime. |
      | scope | required | Scope of access authorized. Note that this can be different from the scopes requested by the app. |
    DESCRIPTION
    # link 'http://hl7.org/fhir/uv/bulkdata/STU1.0.1/authorization/index.html#issuing-access-tokens'

    input :authentication_response
    output :bearer_token

    run do
      skip_if authentication_response.blank?, 'No authentication response received.'

      assert_valid_json(authentication_response)
      response_body = JSON.parse(authentication_response)

      access_token = response_body['access_token']
      assert access_token.present?, 'Token response did not contain access_token as required'

      output bearer_token: access_token

      required_keys = ['token_type', 'expires_in', 'scope']

      required_keys.each do |key|
        assert response_body[key].present?, "Token response did not contain #{key} as required"
      end
    end
  end
end