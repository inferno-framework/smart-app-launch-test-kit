require_relative 'client_assertion_builder'
require_relative 'token_exchange_test'

module SMARTAppLaunch
  class TokenExchangeSTU2Test < TokenExchangeTest
    title 'OAuth token exchange request succeeds when supplied correct information'
    description %(
      After obtaining an authorization code, the app trades the code for an
      access token via HTTP POST to the EHR authorization server's token
      endpoint URL, using content-type application/x-www-form-urlencoded, as
      described in section [4.1.3 of
      RFC6749](https://tools.ietf.org/html/rfc6749#section-4.1.3).
    )
    id :smart_token_exchange_stu2

    def add_credentials_to_request(oauth2_params, oauth2_headers)
      if auth_info.auth_type == 'symmetric'
        assert auth_info.client_secret.present?,
               'A client secret must be provided when using confidential symmetric client authentication.'

        client_credentials = "#{auth_info.client_id}:#{auth_info.client_secret}"
        oauth2_headers['Authorization'] = "Basic #{Base64.strict_encode64(client_credentials)}"
      elsif auth_info.auth_type == 'public'
        oauth2_params[:client_id] = auth_info.client_id
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
