require_relative 'app_protection_group/authenticated_transmission_test'
require_relative 'app_protection_group/bearer_token_cookies_test'
require_relative 'app_protection_group/forward_values_test'
require_relative 'app_protection_group/state_param_generation_test'
require_relative 'app_protection_group/state_param_validation_test'
require_relative 'app_protection_group/untrusted_user_inputs_test'

module SMARTAppLaunch
  class AppProtectionAttestationGroup < Inferno::TestGroup
    id :app_protection_group
    title 'App Protection'

    run_as_group
    test from: :authenticated_transmission
    test from: :bearer_token_cookies
    test from: :forward_values
    test from: :state_param_generation
    test from: :state_param_validation
    test from: :untrusted_user_inputs
  end
end
