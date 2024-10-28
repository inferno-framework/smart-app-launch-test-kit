require_relative 'url_helpers'

module SMARTAppLaunch
  class CORSWellKnownEndpointTest < Inferno::Test
    include URLHelpers

    title 'SMART .well-known/smart-configuration Endpoint Enables Cross-Origin Resource Sharing (CORS)'
    id :smart_cors_well_known_endpoint
    description %(
      The SMART [Considerations for Cross-Origin Resource Sharing (CORS) support](http://hl7.org/fhir/smart-app-launch/STU2.2/app-launch.html#considerations-for-cross-origin-resource-sharing-cors-support)
      specifies that servers that support purely browser-based apps SHALL enable Cross-Origin Resource Sharing (CORS)
      as follows:

        - For requests from any origin, CORS configuration permits access to the public discovery endpoints
          (.well-known/smart-configuration and metadata).

      This test verifies that the .well-known/smart-configuration request is returned with the appropriate CORS header.
    )
    optional

    input :url,
          title: 'FHIR Endpoint',
          description: 'URL of the FHIR endpoint used by SMART applications'

    run do
      well_known_configuration_url = "#{url.chomp('/')}/.well-known/smart-configuration"
      inferno_origin = Inferno::Application['inferno_host']

      get(well_known_configuration_url,
          headers: { 'Accept' => 'application/json',
                     'Origin' => inferno_origin })
      assert_response_status(200)

      cors_allow_origin = request.response_header('Access-Control-Allow-Origin')&.value
      assert cors_allow_origin.present?, 'No `Access-Control-Allow-Origin` header received.'
      assert cors_allow_origin == inferno_origin || cors_allow_origin == '*',
             "`Access-Control-Allow-Origin` must be `#{inferno_origin}`, but received: `#{cors_allow_origin}`"
    end
  end
end
