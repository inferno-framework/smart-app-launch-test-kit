module SMARTAppLaunch
  class CORSTokenExchangeTest < Inferno::Test
    title 'SMART Token Endpoint Enables Cross-Origin Resource Sharing (CORS)'
    description %(
      For requests from a client's registered origin(s), CORS configuration permits access to the token
      endpoint. This test verifies that the token endpoint contains the appropriate CORS header in the
      response.
    )
    id :smart_cors_token_exchange
    optional

    uses_request :cors_token_request

    input :client_auth_type

    run do
      omit_if client_auth_type != 'public'

      skip_if request.status != 200, 'Previous request was unsuccessful, cannot check for CORS support'

      inferno_origin = Inferno::Application['inferno_host']
      cors_header = request.response_header('Access-Control-Allow-Origin')&.value

      assert cors_header == inferno_origin || cors_header == '*',
             "Request must have `Access-Control-Allow-Origin` header containing `#{inferno_origin}`"
    end
  end
end
