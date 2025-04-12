require_relative 'registration_alca_verification_test'
require_relative 'registration_alcs_verification_test'
require_relative 'registration_alp_verification_test'
require_relative 'registration_bsca_verification_test'
require_relative 'client_options'

module SMARTAppLaunch
  class SMARTClientRegistration < Inferno::TestGroup
    id :smart_client_registration
    title 'Client Registration'
    description %(
      During these tests, Inferno will verify the provided registration details as appropriate
      for the selected client type.
    )
    run_as_group

    test from: :smart_client_registration_alca_verification,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_CONFIDENTIAL_ASYMMETRIC
         }
    test from: :smart_client_registration_alcs_verification,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_CONFIDENTIAL_SYMMETRIC
         }
    test from: :smart_client_registration_alp_verification,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_PUBLIC
         }
    test from: :smart_client_registration_bsca_verification,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_BACKEND_SERVICES_CONFIDENTIAL_ASYMMETRIC
         }
  end
end
