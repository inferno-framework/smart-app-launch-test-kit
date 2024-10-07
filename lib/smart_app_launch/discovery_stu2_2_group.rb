require_relative 'well_known_capabilities_stu2_test'
require_relative 'cors_support_stu2_2_test'
require_relative 'well_known_endpoint_stu2_2_test'
require_relative 'cors_enababled_metadata_request_test'

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

    test from: :smart_cors_support_stu2_2,
         title: 'SMART .well-known/smart-configuration Endpoint Enables Cross-Origin Resource Sharing (CORS)',
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

    test from: :smart_cors_enabled_metadata_request
  end
end
