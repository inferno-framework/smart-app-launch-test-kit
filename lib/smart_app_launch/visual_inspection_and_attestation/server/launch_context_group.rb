require_relative 'launch_context_group/launch_context_authorization_test'
require_relative 'launch_context_group/launch_context_parameters_test'

module SMARTAppLaunch
  class LaunchContextAttestationGroup < Inferno::TestGroup
    id :launch_context_group
    title 'Launch Context'

    run_as_group
    test from: :launch_context_authorization
    test from: :launch_context_parameters
  end
end
