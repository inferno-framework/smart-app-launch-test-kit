require_relative 'token_exchange_stu2_test'

module SMARTAppLaunch
  class TokenExchangeSTU22Test < TokenExchangeSTU2Test
    id :smart_token_exchange_stu2_2

    input :auth_info,
          type: :auth_info,
          options: {
            mode: 'auth',
            components: [
              {
                name: :auth_type,
                type: 'select',
                default: 'public',
                options: {
                  list_options: [
                    {
                      label: 'Public',
                      value: 'public'
                    },
                    {
                      label: 'Confidential Symmetric',
                      value: 'symmetric'
                    },
                    {
                      label: 'Confidential Asymmetric',
                      value: 'asymmetric'
                    }
                  ]
                }
              },
              {
                name: :pkce_support,
                default: 'enabled',
                locked: true
              },
              {
                name: :pkce_code_challenge_method,
                default: 'S256',
                locked: true
              },
              {
                name: :requested_scopes,
                type: 'textarea'
              },
              {
                name: :use_discovery,
                locked: true
              }
            ]
          }

    def add_credentials_to_request(oauth2_params, oauth2_headers)
      if auth_info.auth_type == 'symmetric'
        assert auth_info.client_secret.present?,
               'A client secret must be provided when using confidential symmetric client authentication.'

        client_credentials = "#{auth_info.client_id}:#{auth_info.client_secret}"
        oauth2_headers['Authorization'] = "Basic #{Base64.strict_encode64(client_credentials)}"
      elsif auth_info.auth_type == 'public'
        oauth2_params[:client_id] = auth_info.client_id
        oauth2_headers['Origin'] = Inferno::Application['inferno_host']
      else
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
