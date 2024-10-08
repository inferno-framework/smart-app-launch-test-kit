require_relative 'url_helpers'

module SMARTAppLaunch
  class CORSEnabledMetadataRequest < Inferno::Test
    id :smart_cors_enabled_metadata_request

    include URLHelpers

    title 'SMART metadata Endpoint Enables Cross-Origin Resource Sharing (CORS)'
    description %(
    For requests from any origin, CORS configuration permits access to the public discovery endpoints
    (.well-known/smart-configuration and metadata). This test verifies that the metadata
    request is returned with the appropriate CORS header.
  )

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
