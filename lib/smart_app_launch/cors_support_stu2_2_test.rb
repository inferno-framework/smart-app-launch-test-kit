module SMARTAppLaunch
  class CORSSupportTestSTU22 < Inferno::Test
    title 'Endpoint Enables Cross-Origin Resource Sharing (CORS)'
    description %(
      Servers that support purely browser-based apps SHALL enable Cross-Origin Resource Sharing (CORS) as follows:

        - For requests from any origin, CORS configuration permits access to the public discovery endpoints
        (.well-known/smart-configuration and metadata)
        - For requests from a client's registered origin(s), CORS configuration permits access to the token endpoint
        and to FHIR REST API endpoints

        This test ensures the response contains the correct HTTP CORS headers.
    )
    id :smart_cors_support_stu2_2

    uses_request :cors_request

    run do
      skip_if request.status != 200, 'Previous request was unsuccessful, cannot check for CORS support'

      inferno_origin = Inferno::Application['inferno_host']
      cors_header = request.response_header('Access-Control-Allow-Origin')&.value

      assert cors_header == inferno_origin || cors_header == '*',
             "Request must have `Access-Control-Allow-Origin` header containing `#{inferno_origin}`"
    end
  end
end
