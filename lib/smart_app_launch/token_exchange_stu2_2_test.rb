require_relative 'token_exchange_stu2_test'

module SMARTAppLaunch
  class TokenExchangeSTU22Test < TokenExchangeSTU2Test
    id :smart_token_exchange_stu2_2

    input :smart_auth_info, type: :auth_info, options: { mode: 'auth' }

    def add_credentials_to_request(oauth2_params, oauth2_headers)
      if smart_auth_info.auth_type == 'symmetric'
        assert smart_auth_info.client_secret.present?,
               'A client secret must be provided when using confidential symmetric client authentication.'

        client_credentials = "#{smart_auth_info.client_id}:#{smart_auth_info.client_secret}"
        oauth2_headers['Authorization'] = "Basic #{Base64.strict_encode64(client_credentials)}"
      elsif smart_auth_info.auth_type == 'public'
        oauth2_params[:client_id] = smart_auth_info.client_id
        oauth2_headers['Origin'] = Inferno::Application['inferno_host']
      else
        oauth2_params.merge!(
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          client_assertion: ClientAssertionBuilder.build(
            iss: smart_auth_info.client_id,
            sub: smart_auth_info.client_id,
            aud: smart_auth_info.token_url,
            client_auth_encryption_method: smart_auth_info.encryption_algorithm
          )
        )
      end
    end
  end
end
