module SMARTAppLaunch
  module TokenRequestVerification
    
    def verify_token_requests(oauth_flow, authentication_approach)
      jti_list = []
      token_list = []
      requests.each_with_index do |token_request, index|
        request_params = URI.decode_www_form(token_request.request_body).to_h
        request_params['grant_type'] != 'refresh_token' ?
          check_request_params(request_params, oauth_flow, authentication_approach, index + 1) :
          check_refresh_request_params(request_params, oauth_flow, authentication_approach, index + 1)
        check_authentication(authentication_approach, token_request, request_params, jti_list, index + 1)
        
        token_list << extract_token_from_response(token_request)
      end

      output smart_tokens: token_list.compact.join("\n")
    end
    
    def check_request_params(params, oauth_flow, authentication_approach, request_num)
      if params['grant_type'] != oauth_flow
        add_message('error',
                    "Token request #{request_num} had an incorrect `grant_type`: expected #{oauth_flow}, " \
                    "but got '#{params['grant_type']}'")
      end
      if authentication_approach == CONFIDENTIAL_ASYMMETRIC_TAG && 
         params['client_assertion_type'] != 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
        add_message('error',
                    "Confidential asymmetric token request #{request_num} had an incorrect `client_assertion_type`: " \
                    "expected 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer', " \
                    "but got '#{params['client_assertion_type']}'")
      end
      if oauth_flow == CLIENT_CREDENTIALS_TAG && params['scope'].blank?
        add_message('error', "Client credentials token request #{request_num} did not include the requested `scope`")
      end
      if authentication_approach == PUBLIC_TAG && params['client_id'] != client_id
        add_message('error', "Public client token request #{request_num} had an incorrect `client` value: " \
                             "expected '#{client_id}' but got '#{params['client_id']}'")
      end

      check_authorization_code_request_params(params, request_num) if oauth_flow == AUTHORIZATION_CODE_TAG

      nil
    end

    def check_authorization_code_request_params(params, request_num)
      if params['code'].present?

        authorization_request = MockSMARTServer.authorization_request_for_code(params['code'], test_session_id)

        if authorization_request.present?
          authorization_body = MockSMARTServer.authorization_code_request_details(authorization_request)

          if params['redirect_uri'] != authorization_body['redirect_uri']
            add_message('error', "Authorization code token request #{request_num} included an incorrect " \
                                 "`redirect_uri` value: expected '#{authorization_body['redirect_uri']} " \
                                 "but got '#{params['redirect_uri']}'")
          end

          pkce_error = MockSMARTServer.pkce_error(params['code_verifier'],
                                                  authorization_body['code_challenge'],
                                                  authorization_body['code_challenge_method'])
          if pkce_error.present?
            add_message('error', 'Error performing pkce verification on the `code_verifier` value in ' \
                                 "authorization code token request #{request_num}: #{pkce_error}")
          end
        else
          add_message('error', "Authorization code token request #{request_num} included a code not " \
                               "issued during this test session: '#{params['code']}'")
        end
      else
        add_message('error', "Authorization code token request #{request_num} missing a `code`")
      end
    end

    def check_refresh_request_params(params, oauth_flow, authentication_approach, request_num)
      if oauth_flow == CLIENT_CREDENTIALS_TAG
        add_message('error',
                    "Invalid refresh request #{request_num} found during client_credentials flow.")
        return
      end
      
      if params['grant_type'] != 'refresh_token'
        add_message('error',
                    "Refresh request #{request_num} had an incorrect `grant_type`: expected 'refresh_token', " \
                    "but got '#{params['grant_type']}'")
      end
      if authentication_approach == CONFIDENTIAL_ASYMMETRIC_TAG && 
          params['client_assertion_type'] != 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
        add_message('error',
                    "Confidential asymmetric refresh request #{request_num} had an incorrect `client_assertion_type`: " \
                    "expected 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer', " \
                    "but got '#{params['client_assertion_type']}'")
      end

      authorization_code = MockSMARTServer.refresh_token_to_authorization_code(params['refresh_token'])
      authorization_request = MockSMARTServer.authorization_request_for_code(authorization_code, test_session_id)
      if authorization_request.present?
        # todo - check that the scope is a subset of the original authorization code request
      else
        add_message('error', "Authorization code token refresh request #{request_num} included a refresh token not " \
                             "issued during this test session: '#{params['refresh_token']}'")
      end

      nil
    end

    def extract_token_from_response(request)
      return unless request.status == 200

      JSON.parse(request.response_body)&.dig('access_token')
    rescue
      nil
    end
  end
end