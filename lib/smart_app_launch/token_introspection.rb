module SMARTAppLaunch
  class TokenIntrospectionTestGroup < Inferno::TestGroup
    title 'Token Introspection Group'
    description %(TODO)
    id :token_introspection_test_group

    test do
      title 'Token introspection endpoint returns correct response for valid token'
      input :token_introspection_base_url,
            :token_introspection_endpoint,
            :client_id
      input :client_secret, optional: true
      input :standalone_access_token
      output :token_introspection_url

      http_client do
        url :token_introspection_base_url
      end

      run do
        begin
          payload, header =
            JWT.decode(
              standalone_access_token,
              nil,
              false
            )
            # puts "Access token payload = #{payload}}"
        rescue StandardError => e
          assert false, "Access token is not a properly constructed JWT: #{e.message}"
        end

        headers = {'Accept' => 'application/json', 'Content-Type' => 'application/x-www-form-urlencoded'}
        body = "token=#{standalone_access_token}"
        unless client_secret.blank?
          body += "&client_id=#{client_id}&client_secret=#{client_secret}"
        end
        puts 'Body = ' + body
        post(token_introspection_endpoint, body: body, headers: headers)
        assert_response_status(200)
        assert_valid_json(request.response_body)

        # check contents
        introspection_response_body = JSON.parse(request.response_body)
        active_value = introspection_response_body['active']
        client_id_value = introspection_response_body['client_id']
        scope_value = introspection_response_body['scope']
        exp_value = introspection_response_body['exp']

        assert active_value == true, 'Failure: active not set to true for valid token'
        assert client_id_value == payload['client_id'], 'Failure: client_id field does not match between introspection response and original access token'
        assert scope_value == payload['scope'], 'Failure: scope field does not match between introspection response and original access token'
        assert exp_value == payload['exp'], 'Failure: exp field does not match between introspection response and original access token'
      end
    end

    test do 
      title 'Token introspection endpoint returns correct response for invalid token'
      # TODO fix duplicated code
      input :token_introspection_base_url,
            :token_introspection_endpoint,
            :client_id
      input :client_secret, optional: true
      input :standalone_access_token
      output :token_introspection_url

      http_client do
        url :token_introspection_base_url
      end

      run do
        headers = {'Accept' => 'application/json', 'Content-Type' => 'application/x-www-form-urlencoded'}
        body = "token=#{'fake_token_value'}"
        post(token_introspection_endpoint, body: body, headers: headers)
        assert_response_status(401)
      end
    end
  end
end