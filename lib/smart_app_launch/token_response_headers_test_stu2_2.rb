module SMARTAppLaunch
  class TokenResponseHeadersTestSTU22 < Inferno::Test
    title 'Response includes correct HTTP Cache-Control and Pragma headers'
    description %(
      The authorization servers response must include the HTTP Cache-Control
      response header field with a value of no-store, as well as the Pragma
      response header field with a value of no-cache.

      For requests from a client's registered origin(s), CORS configuration permits access to the token endpoint.
      This test verifies that the token endpoint contains the appropriate CORS header in the response.
    )
    id :smart_token_response_headers_stu2_2

    uses_request :token

    run do
      skip_if request.status != 200, 'Token exchange was unsuccessful'

      inferno_origin = Inferno::Application['base_url']
      cors_header = request.response_header('Access-Control-Allow-Origin')&.value

      assert cors_header == inferno_origin,
             "Token response must have `Access-Control-Allow-Origin` header containing `#{inferno_origin}`"

      cc_header = request.response_header('Cache-Control')&.value

      assert cc_header&.downcase&.include?('no-store'),
             'Token response must have `Cache-Control` header containing `no-store`.'

      pragma_header = request.response_header('Pragma')&.value

      assert pragma_header&.downcase&.include?('no-cache'),
             'Token response must have `Pragma` header containing `no-cache`.'
    end
  end
end
