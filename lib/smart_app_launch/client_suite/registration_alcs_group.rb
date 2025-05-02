require_relative 'registration_alcs_verification_test'

module SMARTAppLaunch
  class SMARTClientRegistrationAppLaunchConfidentialSymmetric < Inferno::TestGroup
    id :smart_client_registration_alcs
    title 'SMART App Launch Confidential Symmetric Client Registration'
    description %(
      During these tests, Inferno will verify the provided registration details for the
      SMART App Launch client using Confidential Symmetric authentication. 
    )
    run_as_group

    test from: :smart_client_registration_alcs_verification
  end
end
