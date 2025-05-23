require_relative 'url_helpers'

module SMARTAppLaunch
  class CORSMetadataRequest < Inferno::Test
    id :smart_cors_metadata_request
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@16'

    include URLHelpers

    title 'SMART metadata Endpoint Enables Cross-Origin Resource Sharing (CORS)'
    description %(
      The SMART [Considerations for Cross-Origin Resource Sharing (CORS) support](http://hl7.org/fhir/smart-app-launch/STU2.2/app-launch.html#considerations-for-cross-origin-resource-sharing-cors-support)
      specifies that servers that support purely browser-based apps SHALL enable Cross-Origin Resource Sharing (CORS)
      as follows:

        - For requests from any origin, CORS configuration permits access to the public discovery endpoints
          (.well-known/smart-configuration and metadata).

      This test verifies that the metadata request is returned with the appropriate CORS header.
    )
    optional

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@16'

    input :url

    fhir_client do
      url :url
      headers 'Origin' => Inferno::Application['inferno_host']
    end

    run do
      fhir_get_capability_statement

      assert_response_status(200)
      inferno_origin = Inferno::Application['inferno_host']
      cors_allow_origin = request.response_header('Access-Control-Allow-Origin')&.value
      assert cors_allow_origin.present?, 'No `Access-Control-Allow-Origin` header received.'
      assert cors_allow_origin == inferno_origin || cors_allow_origin == '*',
             "`Access-Control-Allow-Origin` must be `#{inferno_origin}`, but received: `#{cors_allow_origin}`"
    end
  end
end
