require_relative 'standalone_launch_group_stu2_2'

module SMARTAppLaunch
  class SMARTTokenIntrospectionAccessTokenGroupSTU22 < Inferno::TestGroup
    title 'Request New Access Token to Introspect'
    run_as_group

    id :smart_token_introspection_access_token_group_stu2_2

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@270',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@373'

    description %(
      These tests are repeated from the Standalone Launch tests in order to receive a new, active access token that
      will be provided for token introspection. This test group may be skipped if the tester can obtain an access token
      __and__ the contents of the access token response body by some other means.

      These tests are currently designed such that the token introspection URL must be present in the SMART well-known endpoint.

    )

    input_instructions %(
      Register Inferno as a Standalone SMART App and provide the registration details below.
    )

    group from: :smart_discovery_stu2_2,
          config: {
            inputs: {
              smart_auth_info: { name: :standalone_smart_auth_info }
            },
            outputs: {
              smart_auth_info: { name: :standalone_smart_auth_info }
            }
          }
    group from: :smart_standalone_launch_stu2_2
  end
end
