require_relative 'client_registration_verification_test'

module SMARTAppLaunch
  class SMARTClientRegistration < Inferno::TestGroup
    id :smart_client_registration
    title 'Client Registration'
    description %(
      During these tests, Inferno will verify the registration details provided as inputs,
      including the client's JSON Web Key Set.
    )
    run_as_group

    test from: :smart_client_registration_verification
  end
end
