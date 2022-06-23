require_relative 'standalone_launch_group'

module SMARTAppLaunch
  class StandaloneLaunchGroupSTU2 < StandaloneLaunchGroup
    id :smart_standalone_launch_stu2
    description %(
      # Background

      The [Standalone
      Launch Sequence](https://www.hl7.org/fhir/smart-app-launch/1.0.0/index.html#standalone-launch-sequence)
      allows an app, like Inferno, to be launched independent of an
      existing EHR session. It is one of the two launch methods described in
      the SMART App Launch Framework alongside EHR Launch. The app will
      request authorization for the provided scope from the authorization
      endpoint, ultimately receiving an authorization token which can be used
      to gain access to resources on the FHIR server.

      # Test Methodology

      Inferno will redirect the user to the the authorization endpoint so that
      they may provide any required credentials and authorize the application.
      Upon successful authorization, Inferno will exchange the authorization
      code provided for an access token.

      For more information on the #{title}:

      * [Standalone Launch Sequence](https://www.hl7.org/fhir/smart-app-launch/1.0.0/index.html#standalone-launch-sequence)
    )

    config(
      inputs: {
        use_pkce: {
          default: 'true',
          locked: true
        },
        pkce_code_challenge_method: {
          default: 'S256',
          locked: true
        }
      }
    )
  end
end
