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
      if smart_auth_info.asymmetric_auth?
        oauth2_params.merge!(
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          client_assertion: ClientAssertionBuilder.build(
            iss: smart_auth_info.client_id,
            sub: smart_auth_info.client_id,
            aud: smart_auth_info.token_url,
            client_auth_encryption_method: smart_auth_info.encryption_algorithm
          )
        )
      else
        super
      end
    end
  end
end
