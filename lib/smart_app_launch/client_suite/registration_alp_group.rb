
require_relative 'registration_alp_verification_test'

module SMARTAppLaunch
  class SMARTClientRegistrationAppLaunchPublic < Inferno::TestGroup
    id :smart_client_registration_alp
    title 'SMART App Launch Public Client Registration'
    description %(
      During these tests, Inferno will verify the provided registration details for the
      SMART App Launch client using Confidential Symmetric authentication.
    )
    run_as_group

    test from: :smart_client_registration_alp_verification
  end
end
