require_relative 'registration_bsca_verification_test'

module SMARTAppLaunch
  class SMARTClientRegistrationBackendServicesConfidentialAsymmetric < Inferno::TestGroup
    id :smart_client_registration_bsca
    title 'Backend Services Confidential Asymmetric Client Registration'
    description %(
      During these tests, Inferno will verify the provided registration details  for the
      SMART Backend Services client using Confidential Asymmetric authentication.
    )
    run_as_group

    test from: :smart_client_registration_bsca_verification
  end
end
