module SMARTAppLaunch
  class TokenExchangeTest < Inferno::Test
    title 'OAuth token exchange request succeeds when supplied correct information'
    description %(
      After obtaining an authorization code, the app trades the code for an
      access token via HTTP POST to the EHR authorization server's token
      endpoint URL, using content-type application/x-www-form-urlencoded, as
      described in section [4.1.3 of
      RFC6749](https://tools.ietf.org/html/rfc6749#section-4.1.3).
    )
    id :smart_token_exchange
    input :code
    input :pkce_code_verifier, optional: true
    input :smart_auth_info, type: :auth_info, options: { mode: 'auth' }

    output :token_retrieval_time, :smart_credentials, :smart_auth_info

    uses_request :redirect
    makes_request :token

    def default_redirect_uri
      "#{Inferno::Application['base_url']}/custom/smart/redirect"
    end

    def redirect_uri
      config.options[:redirect_uri].presence || default_redirect_uri
    end

    def add_credentials_to_request(oauth2_params, oauth2_headers)
      if smart_auth_info.client_secret.present?
        client_credentials = "#{smart_auth_info.client_id}:#{smart_auth_info.client_secret}"
        oauth2_headers['Authorization'] = "Basic #{Base64.strict_encode64(client_credentials)}"
      else
        oauth2_params[:client_id] = smart_auth_info.client_id
      end
    end

    run do
      skip_if request.query_parameters['error'].present?, 'Error during authorization request'

      oauth2_params = {
        code:,
        redirect_uri:,
        grant_type: 'authorization_code'
      }
      oauth2_headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      add_credentials_to_request(oauth2_params, oauth2_headers)

      oauth2_params[:code_verifier] = pkce_code_verifier if smart_auth_info.pkce_support == 'enabled'

      post(smart_auth_info.token_url, body: oauth2_params, name: :token, headers: oauth2_headers)

      assert_response_status(200)
      assert_valid_json(request.response_body)

      smart_auth_info.issue_time = Time.now

      token_response_body = JSON.parse(request.response_body)

      smart_auth_info.refresh_token = token_response_body['refresh_token']
      smart_auth_info.access_token = token_response_body['access_token']
      smart_auth_info.expires_in = token_response_body['expires_in']

      output smart_credentials: smart_auth_info,
             token_retrieval_time: smart_auth_info.issue_time.iso8601,
             smart_auth_info: smart_auth_info
    end
  end
end
