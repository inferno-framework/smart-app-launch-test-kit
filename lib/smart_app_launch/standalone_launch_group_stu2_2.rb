require_relative 'token_response_body_test_stu2_2'
require_relative 'cors_support_stu2_2_test'
require_relative 'standalone_launch_group_stu2'
require_relative 'token_exchange_stu2_2_test'

module SMARTAppLaunch
  class StandaloneLaunchGroupSTU22 < StandaloneLaunchGroupSTU2
    id :smart_standalone_launch_stu2_2
    description %(
      # Background

      The [Standalone
      Launch Sequence](http://hl7.org/fhir/smart-app-launch/STU2.2/app-launch.html#launch-app-standalone-launch)
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

      * [Standalone Launch Sequence](http://hl7.org/fhir/smart-app-launch/STU2.2/app-launch.html#launch-app-standalone-launch)
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
        },
        requested_scopes: {
          default: 'launch/patient openid fhirUser offline_access patient/*.rs'
        }
      }
    )

    test from: :smart_token_exchange_stu2_2

    token_exchange_index = children.find_index { |child| child.id.to_s.end_with? 'token_exchange' }
    children[token_exchange_index] = children.pop

    test from: :smart_token_response_body_stu2_2

    token_response_body_index = children.find_index { |child| child.id.to_s.end_with? 'token_response_body' }
    children[token_response_body_index] = children.pop

    test from: :smart_cors_support_stu2_2,
         title: 'SMART Token Endpoint Enables Cross-Origin Resource Sharing (CORS)',
         description: %(
                For requests from a client's registered origin(s), CORS configuration permits access to the token
                endpoint. This test verifies that the token endpoint contains the appropriate CORS header in the
                response.
              ),
         config: {
           requests: {
             cors_request: { name: :standalone_token }
           }
         }
  end
end
