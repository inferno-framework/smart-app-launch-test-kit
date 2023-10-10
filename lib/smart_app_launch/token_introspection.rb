module SMARTAppLaunch
  class TokenIntrospectionTestGroup < Inferno::TestGroup
    title 'Token Introspection Group'
    description %(TODO)
    id :token_introspection_test_group

    def get_access_token()
      # todo
    end

    test do
      title 'Token introspection endpoint returns correct response for valid token'
      input :token_introspection_base_url, default: 'http://keycloak_auth_server:8080/realms/inferno'
      input :token_introspection_endpoint, default: 'http://keycloak_auth_server:8080/realms/inferno/protocol/openid-connect/token/introspect'
      input :client_id, default: 'inferno_client_confidential'
      input :client_secret, optional: true, default: 'lLICFElPPfdcRQGnUcFjqAWexB1T6pqb'
      input :access_token
      output :access_token_payload

      http_client do
        url :token_introspection_base_url
      end

      def test_content_fields(field_name, intr_val, access_val)
        error_msg = "Failure: expected introspection response value for '#{field_name}', #{intr_val}, to match corresponding value in original access token, #{access_val}"
        assert intr_val == access_val, error_msg
      end 

      run do
        begin
          access_token_payload, access_token_header =
            JWT.decode(
              access_token,
              nil,
              false
            )
            output access_token_payload: access_token_payload
        rescue StandardError => e
          assert false, "Access token is not a properly constructed JWT: #{e.message}"
        end

        headers = {'Accept' => 'application/json', 'Content-Type' => 'application/x-www-form-urlencoded'}
        body = "token=#{access_token}"
        unless client_secret.blank?
          body += "&client_id=#{client_id}&client_secret=#{client_secret}&scope=openid"
        end

        post(token_introspection_endpoint, body: body, headers: headers)

        assert_response_status(200)
        assert_valid_json(request.response_body)

        introspection_response_body = JSON.parse(request.response_body)

        # required fields for all
        assert introspection_response_body['active'] == true, "Failure: expected introspection response for 'active' to be true for valid token"
        test_content_fields('client_id', introspection_response_body['client_id'], access_token_payload['client_id'])
        # scope test should also account for condtional inclusion of launch context parameter(s), as they would be part of scope
        test_content_fields('scope', introspection_response_body['scope'], access_token_payload['scope'])
        test_content_fields('exp', introspection_response_body['exp'], access_token_payload['exp'])

        # conditional fields based on access token
        if access_token_payload.has_key?('id_token')
          puts 'test for id_token fields'
        else
          puts 'id_token field not found in access token'
        end
      end
    end

    # test do 
    #   title 'Token introspection endpoint returns correct response for invalid token'
    #   # TODO fix duplicated code
    #   input :token_introspection_base_url,
    #         :token_introspection_endpoint,
    #         :client_id
    #   input :client_secret, optional: true
    #   input :access_token
    #   output :token_introspection_url

    #   http_client do
    #     url :token_introspection_base_url
    #   end

    #   run do
    #     headers = {'Accept' => 'application/json', 'Content-Type' => 'application/x-www-form-urlencoded'}
    #     body = "token=#{'fake_token_value'}"
    #     post(token_introspection_endpoint, body: body, headers: headers)
    #     assert_response_status(401)
    #   end
    # end
  end
end