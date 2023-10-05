module SMARTAppLaunch
  class TokenIntrospectionTestGroup < Inferno::TestGroup
    title 'Token Introspection Group'
    description %(TODO)
    id :token_introspection_test_group

    test do
      title 'Token introspection endpoint returns correct response for valid token'
      # base url is really just auth server base url I believe
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
        body = "token=#{standalone_access_token}"
        unless client_secret.blank?
          body += "&client_id=#{client_id}&client_secret=#{client_secret}"
        end
        puts 'Body = ' + body
        post(token_introspection_endpoint, body: body, headers: headers)
        assert_response_status(200)
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