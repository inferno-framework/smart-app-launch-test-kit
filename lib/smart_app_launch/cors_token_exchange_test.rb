module SMARTAppLaunch
  class CORSTokenExchangeTest < Inferno::Test
    title 'SMART Token Endpoint Enables Cross-Origin Resource Sharing (CORS)'
    description %(
      The SMART [Considerations for Cross-Origin Resource Sharing (CORS) support](http://hl7.org/fhir/smart-app-launch/STU2.2/app-launch.html#considerations-for-cross-origin-resource-sharing-cors-support)
      specifies that servers that support purely browser-based apps SHALL enable Cross-Origin Resource Sharing (CORS)
      as follows:

        - For requests from a client's registered origin(s), CORS configuration permits access to the token
          endpoint

      This test verifies that the token endpoint contains the appropriate CORS header in the response.
    )
    id :smart_cors_token_exchange

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@17'

    uses_request :cors_token_request

    input :client_auth_type

    run do
      omit_if client_auth_type != 'public', %(
        Client type is not public, Cross-Origin Resource Sharing (CORS) is not required to be supported for
        non-public client types
      )

      skip_if request.status != 200, 'Previous request was unsuccessful, cannot check for CORS support'

      inferno_origin = Inferno::Application['inferno_host']
      cors_header = request.response_header('Access-Control-Allow-Origin')&.value

      assert cors_header == inferno_origin || cors_header == '*',
             "Request must have `Access-Control-Allow-Origin` header containing `#{inferno_origin}`"
    end
  end
end
