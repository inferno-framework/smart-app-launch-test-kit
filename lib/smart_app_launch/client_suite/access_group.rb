require_relative 'access_alca_interaction_test'
require_relative 'access_alcs_interaction_test'
require_relative 'access_alp_interaction_test'
require_relative 'access_bsca_interaction_test'
require_relative 'authorization_request_verification_test'
require_relative 'token_request_alca_verification_test'
require_relative 'token_request_alcs_verification_test'
require_relative 'token_request_alp_verification_test'
require_relative 'token_request_bsca_verification_test'
require_relative 'token_use_verification_test'
require_relative '../tags'

module SMARTAppLaunch
  class SMARTClientAccess < Inferno::TestGroup
    id :smart_client_access
    title 'Client Access'
    description %(
      During these tests, the client system will access Inferno's simulated
      FHIR server that is protected using SMART. The client will request
      an access token using the OAuth flow setup during registration and will then
      make a FHIR request using that token.

      Inferno will then verify that any OAuth requests made were conformant
      and that a token returned from a token request was used on an access request.
    )

    run_as_group

    # Access Interaction Test (All, different for each)
    test from: :smart_client_access_alca_interaction,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_CONFIDENTIAL_ASYMMETRIC
         }
    test from: :smart_client_access_alcs_interaction,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_CONFIDENTIAL_SYMMETRIC
         }
    test from: :smart_client_access_alp_interaction,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_PUBLIC
         }
    test from: :smart_client_access_bsca_interaction,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_BACKEND_SERVICES_CONFIDENTIAL_ASYMMETRIC
         }

    # Authorization Request Verification (app launch only, same for each)
    test from: :smart_client_authorization_request_verification,
         id: :smart_client_authorization_request_alca_verification,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_CONFIDENTIAL_ASYMMETRIC
         }
    test from: :smart_client_authorization_request_verification,
         id: :smart_client_authorization_request_alcs_verification,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_CONFIDENTIAL_SYMMETRIC
         }
    test from: :smart_client_authorization_request_verification,
         id: :smart_client_authorization_request_alp_verification,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_PUBLIC
         }
    
    # Access token request (All, different for each)
    test from: :smart_client_token_request_alca_verification,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_CONFIDENTIAL_ASYMMETRIC
         }
    test from: :smart_client_token_request_alcs_verification,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_CONFIDENTIAL_SYMMETRIC
         }
    test from: :smart_client_token_request_alp_verification,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_APP_LAUNCH_PUBLIC
         }
    test from: :smart_client_token_request_bsca_verification,
         required_suite_options: {
           client_type: SMARTClientOptions::SMART_BACKEND_SERVICES_CONFIDENTIAL_ASYMMETRIC
         }

    # Access token use (all the same)
    test from: :smart_client_token_use_verification
  end
end
