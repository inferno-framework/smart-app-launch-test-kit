require_relative 'token_exchange_test'
require_relative 'token_refresh_body_test'

module SMARTAppLaunch
  class TokenIntrospectionTestGroup < Inferno::TestGroup
    title 'Token Introspection Group'
    description %(
      # Background
      OAuth 2.0 Token introspection, as described in [RFC-7662](https://datatracker.ietf.org/doc/html/rfc7662), allows
      an authorized resource server to query an OAuth 2.0 authorization server for metadata on a token.  The
      [SMART App Launch STU 2.1 Implementation Guide Section on Token Introspection](https://hl7.org/fhir/smart-app-launch/token-introspection.html)
      states that "SMART on FHIR EHRs SHOULD support token introspection, which allows a broader ecosystem of resource servers
      to leverage authorization decisions managed by a single authorization server."

      # Test Methodology
      For these tests, Inferno acts as an authorized resource server that queries the authorization server about an access 
      token, rather than a client to a FHIR resource server as in the previous SMART App Launch tests.  The tests will 
      create a request to the authorization server's token introspection endpoint and validate the introspection response.

      The means of discovery of the token introspection endpoint are outside the scope of the RFC-7662 specification.
      As such, Inferno makes no assumptions that that the introspection endpoint is included in the `.well-known` endpoint query and leaves it to be input by the user. 
      
      To complete the tests, Inferno should be registered with the authorization server as an authorized resource server
      capable of accessing the token introspection endpoint.  RFC-7662 requires "some form of authorization" to access
      the token endpoint but does specifiy any one specific approach.  
      )

    id :token_introspection_test_group

    DEFAULT_INTR_BASE_URL = 'http://keycloak_auth_server:8080/realms/inferno'
    DEFAULT_TOKEN_ENDPOINT = 'protocol/openid-connect/token'
    DEFAULT_INTR_ENDPOINT = 'protocol/openid-connect/token/introspect'
    DEFAULT_CLIENT_ID = 'inferno_client_confidential'
    DEFAULT_CLIENT_SECRET = 'lLICFElPPfdcRQGnUcFjqAWexB1T6pqb'

    input :token_introspection_base_url, default: DEFAULT_INTR_BASE_URL
    input :token_introspection_endpoint, default: DEFAULT_INTR_ENDPOINT
    input :client_id, default: DEFAULT_CLIENT_ID
    input :client_secret, optional: true, default: DEFAULT_CLIENT_SECRET

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
      title 'Token introspection endpoint returns correct response for active token'
      description %(
      This test will check whether the metadata in the token introspection response is correct for an active token and that the response data matches the data in the original access token and/or access token response from the authorization server, including the following:
      
      Required:
      *  `active` claim is set to true 
      * `scope`, `client_id`, and `exp` claim(s) match between introspection response and access token

      Conditionally Required:
      * IF launch context parameter(s) included in access token, introspection response includes claim(s) for launch context parameter(s) 
      * IF identity token was included as part of access token response, `iss` and `sub` claims are present in introspection response

      Optional but Recommended:
      * IF identity token was included as part of access token response, `fhirUser` claim SHOULD be present in introspection response
        
      Per [RFC-7662](https://datatracker.ietf.org/doc/html/rfc7662#section-2), "the definition of an active token is currently dependent upon the authorization
      server, but his is commonly a token that has been issued by this authorization server, is not expired, has not been
      revoked, and is valid for use at the protected resource making the introspection call."

      Inferno can either reuse an access token received from a prior SMART App Launch test or request a new one as part of the introspection test. It is up to the user's understanding of their setup to configure the tests such that an active token is provided to the introspection endpoint.

      TODO - provide more configuration options for creating an new access token request.  
      )
      
      input :access_token_source, 
            title: 'Source of access token to introspect',
            type: 'radio',
            default: 'new',
            options: {
              list_options: [
                {
                  label: 'New Request',
                  value: 'new'
                },
                {
                  label: 'Reuse from Standalone Launch Test',
                  value: 'standalone_launch_test'
                },
                {
                  label: 'Reuse from EHR Launch Test',
                  value: 'ehr_launch_test'
                }
              ]
            }
      input :token_endpoint, 
            optional: true, 
            default: DEFAULT_TOKEN_ENDPOINT,
            description: 'Only required if selecting to request a new access token'
      input :standalone_access_token, optional: true, locked: true
      input :ehr_access_token, optional: true, locked: true


      # Keycloak will not include an ID token with its access token response unless this is included
      input :openid_scope, 
            title: 'Include "scope=openid" field',
            description: %(Whether or not to include scope=openid in new access token request, which is required for some auth servers to return an id token with access token response),
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
        if access_token_source == 'new'
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
          intr_access_token = access_token_response['access_token']
        elsif access_token_source == 'standalone_launch_test'
          intr_access_token = standalone_access_token
        elsif access_token_source == 'ehr_launch_test'
          intr_access_token = ehr_access_token
        end

        # Note this will fail with current reference server implementation because it does not return a valid JWT, just
        # a random string 
        begin
          access_token_payload, access_token_header =
            JWT.decode(
              intr_access_token,
              nil,
              false
            )
            output access_token_payload: access_token_payload
        rescue StandardError => e
          assert false, "Access token is not a properly constructed JWT: #{e.message}"
        end

        headers = {'Accept' => 'application/json', 'Content-Type' => 'application/x-www-form-urlencoded'}
        body = "token=#{intr_access_token}"
        headers, body = add_credentials(headers, body, client_id, client_secret)

        post(token_introspection_endpoint, body: body, headers: headers)

        assert_response_status(200)
        assert_valid_json(request.response_body)

        introspection_response_body = JSON.parse(request.response_body)

        # required fields for all
        assert introspection_response_body['active'] == true, "Failure: expected introspection response for 'active' to be true for valid token"
        test_content_fields('client_id', introspection_response_body['client_id'], access_token_payload['client_id'])
        # TODO need to test scope details more thoroughly 
        test_content_fields('scope', introspection_response_body['scope'], access_token_payload['scope'])
        test_content_fields('exp', introspection_response_body['exp'], access_token_payload['exp'])

        # conditional fields based on access token
        id_token_check = access_token_payload.has_key?('id_token')
        if id_token_check == true
          id_token_payload, id_token_header = JWT.decode(access_token_payload['id_token'], nil, false)
          assert introspection_response_body.has_key?('iss'), 
            "Failure: introspection response must have 'iss' claim because ID token was included in original access token response"
          assert introspection_response_body.has_key?('sub'),
            "Failure: introspection response must have 'sub' claim because ID token was included in original access token response"
        end

        # could not get message to display when info block included as part of prior if block
        if id_token_check == true and introspection_response_body.has_key?('fhirUser')
          skip_info_msg = true
        end 
        info do
          assert skip_info_msg == true, 
          'Identity token was returned with original access token response, but no fhirUser claim found in introspection response'
        end
      end
    end

    test do 
      title 'Token introspection endpoint returns correct response for invalid token with valid client ID'
      description %(
        This test will query the introspection endpoint and provide an invalid token in the form of a hardcoded string value.
        The authorization server must return a 200 OK status and have a response with no other data except an `active` claim, which must be set to false. 
      )

      run do
        headers = {'Accept' => 'application/json', 'Content-Type' => 'application/x-www-form-urlencoded'}
        body = "token=invalid_token_value"
        headers, body = add_credentials(headers, body, client_id, client_secret)
        post(token_introspection_endpoint, body: body, headers: headers)
        
        assert_response_status(200)
        assert_valid_json(request.response_body)
        introspection_response_body = JSON.parse(request.response_body)
        assert introspection_response_body['active'] == false, "Failure: expected introspection response for 'active' to be false for invalid token"
        assert introspection_response_body.size == 1, "Failure: expected only 'active' field to be present in introspection response for invalid token"
      end
    end
  end
end