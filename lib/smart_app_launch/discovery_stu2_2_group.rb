require_relative 'cors_metadata_request_test'
require_relative 'cors_well_known_endpoint_test'
require_relative 'discovery_stu2_group'

module SMARTAppLaunch
  class DiscoverySTU22Group < DiscoverySTU2Group
    id :smart_discovery_stu2_2

    test from: :smart_cors_well_known_endpoint
    test from: :smart_cors_metadata_request
  end
end
