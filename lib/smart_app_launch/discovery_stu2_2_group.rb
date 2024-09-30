require_relative 'well_known_capabilities_stu2_test'
require_relative 'cors_support_stu2_2_test'
require_relative 'well_known_endpoint_stu2_2_test'
require_relative 'url_helpers'

module SMARTAppLaunch
  class DiscoverySTU22Group < DiscoverySTU2Group
    id :smart_discovery_stu2_2

    test from: :well_known_endpoint_stu2_2,
         config: {
           outputs: {
             well_known_authorization_url: { name: :smart_authorization_url },
             well_known_token_url: { name: :smart_token_url }
           }
         }

    well_known_index = children.find_index { |child| child.id.to_s.end_with? 'well_known_endpoint' }
    children[well_known_index] = children.pop

    test from: :cors_support_stu2_2,
         title: 'SMART well-known Endpoint Enables Cross-Origin Resource Sharing (CORS)',
         description: %(
                For requests from any origin, CORS configuration permits access to the public discovery endpoints
                (.well-known/smart-configuration and metadata). This test verifies that the
                .well-known/smart-configuration request is returned with the appropriate CORS header.
              ),
         config: {
           requests: {
             cors_request: { name: :smart_well_known_configuration }
           }
         }

    test do
      include URLHelpers

      title 'Conformance/CapabilityStatement Enables Cross-Origin Resource Sharing (CORS)'
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
end
