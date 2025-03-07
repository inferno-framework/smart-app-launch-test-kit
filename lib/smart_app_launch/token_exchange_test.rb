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

    input :code,
          :smart_token_url,
          :client_id
    input :client_secret, optional: true
    input :use_pkce,
          title: 'Proof Key for Code Exchange (PKCE)',
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Enabled',
                value: 'true'
              },
              {
                label: 'Disabled',
                value: 'false'
              }
            ]
          }
    input :pkce_code_verifier, optional: true
    output :token_retrieval_time
    output :smart_credentials
    uses_request :redirect
    makes_request :token

    def default_redirect_uri
      "#{Inferno::Application['base_url']}/custom/smart/redirect"
    end

    def redirect_uri
      config.options[:redirect_uri].presence || default_redirect_uri
    end

    def add_credentials_to_request(oauth2_params, oauth2_headers)
      if client_secret.present?
        client_credentials = "#{client_id}:#{client_secret}"
        oauth2_headers['Authorization'] = "Basic #{Base64.strict_encode64(client_credentials)}"
      else
        oauth2_params[:client_id] = client_id
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

      oauth2_params[:code_verifier] = pkce_code_verifier if use_pkce == 'true'

      post(smart_token_url, body: oauth2_params, name: :token, headers: oauth2_headers)

      assert_response_status(200)
      assert_valid_json(request.response_body)

      output token_retrieval_time: Time.now.iso8601

      token_response_body = JSON.parse(request.response_body)

      output smart_credentials: {
        refresh_token: token_response_body['refresh_token'],
        access_token: token_response_body['access_token'],
        expires_in: token_response_body['expires_in'],
        client_id:,
        client_secret:,
        token_retrieval_time:,
        token_url: smart_token_url
      }.to_json
    end
  end
end
