require_relative 'app_redirect_test_stu2'
require_relative 'token_exchange_stu2_test'
require_relative 'standalone_launch_group'

module SMARTAppLaunch
  class StandaloneLaunchGroupSTU2 < StandaloneLaunchGroup
    id :smart_standalone_launch_stu2
    description %(
      # Background

      The [Standalone
      Launch Sequence](http://hl7.org/fhir/smart-app-launch/STU2/app-launch.html#launch-app-standalone-launch)
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

      * [Standalone Launch Sequence](http://hl7.org/fhir/smart-app-launch/STU2/app-launch.html#launch-app-standalone-launch)
    )

    config(
      inputs: {
        smart_auth_info: {
          name: :standalone_smart_auth_info,
          options: {
            components: [
              {
                name: :requested_scopes,
                default: 'launch/patient openid fhirUser offline_access patient/*.rs'
              },
              {
                name: :pkce_support,
                default: 'enabled',
                locked: true
              },
              {
                name: :pkce_code_challenge_method,
                default: 'S256',
                locked: true
              },
              Inferno::DSL::AuthInfo.default_auth_type_component,
              {
                name: :use_discovery,
                locked: true
              }
            ]
          }
        }
      }
    )

    test from: :smart_app_redirect_stu2

    redirect_index = children.find_index { |child| child.id.to_s.end_with? 'app_redirect' }
    children[redirect_index] = children.pop

    test from: :smart_token_exchange_stu2

    token_exchange_index = children.find_index { |child| child.id.to_s.end_with? 'token_exchange' }
    children[token_exchange_index] = children.pop

    children[token_exchange_index].id('smart_token_exchange')
  end
end
