require_relative 'app_launch_registration_verification_test'

module SMARTAppLaunch
  class SMARTClientAppLaunchRegistration < Inferno::TestGroup
    id :smart_client_app_launch_registration
    title 'SMART App Launch Client Registration'
    description %(
      During these tests, Inferno will verify the registration details provided as inputs,
      including,
      - Launch Details
        - Launch URIs (if the client supports EHR Launch)
        - Redirect URIs
      - Authentication
        - JSON Web Key Set (if the client supports asymmetric authentication)
        - Client secret (if the client supports symmetric authentication)
    )
    run_as_group

    test from: :smart_client_app_launch_registration_verification
  end
end
