require_relative 'token_refresh_test'

module SMARTAppLaunch
  class TokenRefreshSTU2Test < TokenRefreshTest
    include TokenPayloadValidation

    id :smart_token_refresh_stu2
    title 'Server successfully refreshes the access token when optional scope parameter omitted'
    description %(
      Server successfully exchanges refresh token at OAuth token endpoint
      without providing scope in the body of the request.

      Although not required in the token refresh portion of the SMART App
      Launch Guide, the token refresh response should include the HTTP
      Cache-Control response header field with a value of no-store, as well as
      the Pragma response header field with a value of no-cache to be
      consistent with the requirements of the inital access token exchange.
    )

    input :auth_info, type: :auth_info, options: { mode: 'auth' }

    def add_credentials_to_request(oauth2_headers, oauth2_params)
      case auth_info.auth_type
      when 'public'
        oauth2_params['client_id'] = auth_info.client_id
      when 'symmetric'
        assert auth_info.client_secret.present?,
               'A client secret must be provided when using confidential symmetric client authentication.'

        credentials = Base64.strict_encode64("#{auth_info.client_id}:#{auth_info.client_secret}")
        oauth2_headers['Authorization'] = "Basic #{credentials}"
      when 'asymmetric'
        oauth2_params.merge!(
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          client_assertion: ClientAssertionBuilder.build(
            iss: auth_info.client_id,
            sub: auth_info.client_id,
            aud: smart_token_url,
            client_auth_encryption_method: auth_info.encryption_algorithm
          )
        )
      end
    end
  end
end
