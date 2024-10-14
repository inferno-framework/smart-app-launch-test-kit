module SMARTAppLaunch
  class CORSTokenExchangeTest < Inferno::Test
    title 'SMART Token Endpoint Enables Cross-Origin Resource Sharing (CORS)'
    description %(
      For requests from a client's registered origin(s), CORS configuration permits access to the token
      endpoint. This test verifies that the token endpoint contains the appropriate CORS header in the
      response.
    )
    optional

    id :smart_cors_token_exchange

    input :client_auth_encryption_method,
          title: 'Encryption Method (Confidential Asymmetric Client Auth Only)',
          type: 'radio',
          default: 'ES384',
          options: {
            list_options: [
              {
                label: 'ES384',
                value: 'ES384'
              },
              {
                label: 'RS384',
                value: 'RS384'
              }
            ]
          }

    input :client_auth_type,
          title: 'Client Authentication Method',
          type: 'radio',
          default: 'public',
          options: {
            list_options: [
              {
                label: 'Public',
                value: 'public'
              },
              {
                label: 'Confidential Symmetric',
                value: 'confidential_symmetric'
              },
              {
                label: 'Confidential Asymmetric',
                value: 'confidential_asymmetric'
              }
            ]
          }

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
    uses_request :redirect

    config(
      inputs: {
        use_pkce: {
          default: 'true',
          options: {
            list_options: [
              {
                label: 'Enabled',
                value: 'true'
              }
            ]
          }
        }
      },
      options: { redirect_uri: "#{Inferno::Application['base_url']}/custom/smart/redirect" }
    )

    def add_credentials_to_request(oauth2_params, oauth2_headers)
      if client_auth_type == 'confidential_symmetric'
        assert client_secret.present?,
               'A client secret must be provided when using confidential symmetric client authentication.'

        client_credentials = "#{client_id}:#{client_secret}"
        oauth2_headers['Authorization'] = "Basic #{Base64.strict_encode64(client_credentials)}"
      elsif client_auth_type == 'public'
        oauth2_params[:client_id] = client_id
      else
        oauth2_params.merge!(
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          client_assertion: ClientAssertionBuilder.build(
            iss: client_id,
            sub: client_id,
            aud: smart_token_url,
            client_auth_encryption_method:
          )
        )
      end
    end

    run do
      skip_if request.query_parameters['error'].present?, 'Error during authorization request'
      inferno_origin = Inferno::Application['inferno_host']

      oauth2_params = {
        code:,
        redirect_uri: config.options[:redirect_uri],
        grant_type: 'authorization_code'
      }
      oauth2_headers = { 'Content-Type' => 'application/x-www-form-urlencoded',
                         'Origin' => inferno_origin }

      add_credentials_to_request(oauth2_params, oauth2_headers)

      oauth2_params[:code_verifier] = pkce_code_verifier if use_pkce == 'true'

      post(smart_token_url, body: oauth2_params, name: :token, headers: oauth2_headers)

      assert_response_status(200)

      cors_allow_origin = request.response_header('Access-Control-Allow-Origin')&.value
      assert cors_allow_origin.present?, 'No `Access-Control-Allow-Origin` header received.'
      assert cors_allow_origin == inferno_origin || cors_allow_origin == '*',
             "`Access-Control-Allow-Origin` must be `#{inferno_origin}`, but received: `#{cors_allow_origin}`"
    end
  end
end
