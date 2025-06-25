require_relative 'token_payload_validation'

module SMARTAppLaunch
  class TokenRefreshTest < Inferno::Test
    include TokenPayloadValidation

    id :smart_token_refresh
    title 'Server successfully refreshes the access token when optional scope parameter omitted'
    description %(
      Server successfully exchanges refresh token at OAuth token endpoint
      without providing scope in the body of the request.

      Although not required in the token refresh portion of the SMART App
      Launch Guide, the token refresh response should include the HTTP
      Cache-Control response header field with a value of no-store, as well as
      the Pragma response header field with a value of no-cache to be
      consistent with the requirements of the initial access token exchange.
    )
    input :received_scopes
    input :smart_auth_info, type: :auth_info, options: { mode: 'auth' }

    output :smart_credentials, :token_retrieval_time, :smart_auth_info
    makes_request :token_refresh

    def add_credentials_to_request(oauth2_headers, oauth2_params)
      if smart_auth_info.symmetric_auth?
        credentials = Base64.strict_encode64("#{smart_auth_info.client_id}:#{smart_auth_info.client_secret}")
        oauth2_headers['Authorization'] = "Basic #{credentials}"
      else
        oauth2_params['client_id'] = smart_auth_info.client_id
      end
    end

    def make_auth_token_request(smart_token_url, oauth2_params, oauth2_headers)
      post(smart_token_url, body: oauth2_params, name: :token_refresh, headers: oauth2_headers)
    end

    run do
      skip_if smart_auth_info.refresh_token.blank?

      oauth2_params = {
        'grant_type' => 'refresh_token',
        'refresh_token' => smart_auth_info.refresh_token
      }
      oauth2_headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      oauth2_params['scope'] = received_scopes if config.options[:include_scopes]

      add_credentials_to_request(oauth2_headers, oauth2_params)

      make_auth_token_request(smart_auth_info.token_url, oauth2_params, oauth2_headers)

      assert_response_status(200)
      assert_valid_json(request.response_body)

      smart_auth_info.issue_time = Time.now
      token_response_body = JSON.parse(request.response_body)

      smart_auth_info.refresh_token = token_response_body['refresh_token'].presence || smart_auth_info.refresh_token
      smart_auth_info.access_token = token_response_body['access_token']
      smart_auth_info.expires_in = token_response_body['expires_in']

      output smart_credentials: smart_auth_info,
             token_retrieval_time: smart_auth_info.issue_time.iso8601,
             smart_auth_info: smart_auth_info
    end
  end
end
