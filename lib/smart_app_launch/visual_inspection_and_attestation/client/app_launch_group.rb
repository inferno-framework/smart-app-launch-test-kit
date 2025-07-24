require_relative 'app_launch_group/launch_url_param_test'
require_relative 'app_launch_group/request_ehr_context_test'

module SMARTAppLaunch
  class AppLaunchAttestationGroup < Inferno::TestGroup
    id :app_launch_group
    title 'App Launch'

    run_as_group
    test from: :launch_url_param
    test from: :request_ehr_context
  end
end
