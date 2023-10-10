module SMARTAppLaunch
  class TokenIntrospectionTestGroup < Inferno::TestGroup
    title 'Token Introspection Group'
    description %(TODO)
    id :token_introspection_test_group

    DEFAULT_INTR_BASE_URL = 'http://keycloak_auth_server:8080/realms/inferno'
    DEFAULT_TOKEN_ENDPOINT = 'protocol/openid-connect/token'
    DEFAULT_INTR_ENDPOINT = 'protocol/openid-connect/token/introspect'
    DEFAULT_CLIENT_ID = 'inferno_client_confidential'
    DEFAULT_CLIENT_SECRET = 'lLICFElPPfdcRQGnUcFjqAWexB1T6pqb'

    input :token_introspection_base_url, default: DEFAULT_INTR_BASE_URL
    input :token_endpoint, default: DEFAULT_TOKEN_ENDPOINT
    input :token_introspection_endpoint, default: DEFAULT_INTR_ENDPOINT

    http_client do
      url :token_introspection_base_url
    end

    def add_credentials(headers, body, client_id, client_secret)
      if client_secret.blank?
        body += "#{:client_id}=#{client_id}"
      else
        client_credentials = "#{client_id}:#{client_secret}"
        headers['Authorization'] = "Basic #{Base64.strict_encode64(client_credentials)}"
      end
      return headers, body
    end

    test do
      title 'Token introspection endpoint returns correct response for valid token'
      input :client_id, default: DEFAULT_CLIENT_ID
      input :client_secret, optional: true, default: DEFAULT_CLIENT_SECRET
      input :openid_scope, 
            title: 'Include "scope=openid" field',
                type: 'radio',
                default: 'true',
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
      output :access_token_response
      output :access_token_payload

      def test_content_fields(field_name, intr_val, access_val)
        error_msg = "Failure: expected introspection response value for '#{field_name}', #{intr_val}, to match corresponding value in original access token, #{access_val}"
        assert intr_val == access_val, error_msg
      end 

      run do
        tok_req_headers = {'Accept' => 'application/json', 'Content-Type' => 'application/x-www-form-urlencoded'}
        tok_req_body = "grant_type=client_credentials"
        if openid_scope == 'true'
          tok_req_body+="&scope=openid"
        end
        tok_req_headers, tok_req_body = add_credentials(tok_req_headers, tok_req_body, client_id, client_secret)
        post(token_endpoint, body: tok_req_body, headers: tok_req_headers)
        assert_response_status(200)
        assert_valid_json(request.response_body)
        output access_token_response: JSON.parse(request.response_body)

        access_token = access_token_response['access_token']
        
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
        headers, body = add_credentials(headers, body, client_id, client_secret)

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
          # decode token
          id_token_payload, id_token_header = JWT.decode(access_token_payload['id_token'], nil, false)
          # check for introspection response iss to match id token iss
          test_content_fields('iss', introspection_response_body['iss'], id_token_payload['iss'])
          # check for introspection response sub to match id token sub
          test_content_fields('sub', introspection_response_body['sub'], id_token_payload['sub'])
          # create warning/info for fhir user - should be a field in introspection response if id_token in access token
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