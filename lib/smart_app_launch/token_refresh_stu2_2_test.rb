module SMARTAppLaunch
  class TokenRefreshSTU22Test < TokenRefreshSTU2Test
    include TokenPayloadValidation

    id :smart_token_refresh_stu2_2

    def make_auth_token_request(smart_token_url, oauth2_params, oauth2_headers)
      oauth2_headers['Origin'] = Inferno::Application['inferno_host']
      post(smart_token_url, body: oauth2_params, name: :token_refresh, headers: oauth2_headers)
    end
  end
end
