require_relative 'token_exchange_stu2_test'

module SMARTAppLaunch
  class TokenExchangeSTU22Test < TokenExchangeSTU2Test
    id :smart_token_exchange_stu2_2

    input :smart_auth_info, type: :auth_info, options: { mode: 'auth' }

    def add_credentials_to_request(oauth2_params, oauth2_headers)
      if smart_auth_info.public_auth?
        oauth2_params[:client_id] = smart_auth_info.client_id
        oauth2_headers['Origin'] = Inferno::Application['inferno_host']
      else
        super
      end
    end
  end
end
