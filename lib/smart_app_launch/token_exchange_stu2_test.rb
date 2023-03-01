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

    input :encryption_method,
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

    config(
      inputs: {
        client_auth_type: {
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
        }
      }
    )
  end
end
