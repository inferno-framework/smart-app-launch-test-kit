require_relative 'registration_alca_verification_test'

module SMARTAppLaunch
  class SMARTClientRegistrationAppLaunchConfidentialAsymmetric < Inferno::TestGroup
    id :smart_client_registration_alca
    title 'SMART App Launch Confidential Symmetric Client Registration'
    description %(
      During these tests, Inferno will verify the provided registration details for the
      SMART App Launch client using Confidential Asymmetric authentication.
    )
    run_as_group

    test from: :smart_client_registration_alca_verification
  end
end
