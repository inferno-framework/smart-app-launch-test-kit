require_relative 'app_launch_access_interaction_test'
require_relative 'app_launch_authorization_request_verification_test'
require_relative 'app_launch_token_request_verification_test'
require_relative 'app_launch_refresh_request_verification_test'
require_relative '../client_token_use_verification_test'

module SMARTAppLaunch
  class SMARTClientAppLaunchAccess < Inferno::TestGroup
    id :smart_client_app_launch_access
    title 'Client App Launch and Access'
    description %(
      During these tests, the client will be launched and will access Inferno's simulated
      FHIR server. Inferno will then verify that the client was able to use the OAuth
      authorization code flow to obtain an access token and then use that access token
      when requesting data from Inferno's simulated FHIR server.
    )

    run_as_group

    test from: :smart_client_app_launch_access_interaction
    test from: :smart_client_app_launch_authorization_request_verification
    test from: :smart_client_app_launch_token_request_verification
    test from: :smart_client_app_launch_refresh_request_verification
    test from: :smart_client_token_use_verification
  end
end
