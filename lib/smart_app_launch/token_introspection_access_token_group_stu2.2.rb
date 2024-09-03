require_relative 'standalone_launch_group_stu2.2'

module SMARTAppLaunch
  class SMARTTokenIntrospectionAccessTokenGroupSTU22 < SMARTTokenIntrospectionAccessTokenGroup
    title 'Request New Access Token to Introspect'
    run_as_group

    id :smart_token_introspection_access_token_group_stu2_2

    description %(
      These tests are repeated from the Standalone Launch tests in order to receive a new, active access token that
      will be provided for token introspection. This test group may be skipped if the tester can obtain an access token
      __and__ the contents of the access token response body by some other means.

      These tests are currently designed such that the token introspection URL must be present in the SMART well-known endpoint.

    )

    input_instructions %(
      Register Inferno as a Standalone SMART App and provide the registration details below.
    )

    group from: :smart_standalone_launch_stu2_2

    standalone_launch_index = children.find_index { |child| child.id.to_s.end_with? 'standalone_launch_stu2' }
    children[standalone_launch_index] = children.pop
  end
end
