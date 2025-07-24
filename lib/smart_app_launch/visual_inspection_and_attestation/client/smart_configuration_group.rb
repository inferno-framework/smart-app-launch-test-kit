require_relative 'smart_configuration_group/smart_configuration_test'
require_relative 'smart_configuration_group/well_known_smart_config_test'

module SMARTAppLaunch
  class SMARTConfigurationAttestationGroup < Inferno::TestGroup
    id :smart_configuration_group
    title 'SMART Configuration'

    run_as_group
    test from: :smart_configuration
    test from: :well_known_smart_config
  end
end
