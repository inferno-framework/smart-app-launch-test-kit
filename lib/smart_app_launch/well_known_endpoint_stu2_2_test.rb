module SMARTAppLaunch
  class WellKnownEndpointSTU22Test < WellKnownEndpointTest
    id :well_known_endpoint_stu2_2

    def get_well_known_configuration(well_known_configuration_url)
      get(well_known_configuration_url,
          name: :smart_well_known_configuration,
          headers: { 'Accept' => 'application/json', 'Origin' => Inferno::Application['inferno_host'] })
    end
  end
end
