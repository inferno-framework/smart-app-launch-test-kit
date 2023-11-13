require_relative 'standalone_launch_group_stu2'

module SMARTAppLaunch
  class TokenIntrospectionAccessTokenGroup < Inferno::TestGroup
    title 'Request New Access Token to Introspect'
    run_as_group

    id :token_introspection_access_token_group

    description %(
      These tests are repeated from the Standalone Launch tests in order to receive a new, active access token that
      will be provided for token introspection. This test group may be skipped if the tester can obtain an access token
      __and__ the contents of the access token response body by some other means.  
    )
    
    input_instructions %(
      Complete the Standalone Launch test group to auto-populate the inputs.  
    )
    
    group from: :smart_standalone_launch_stu2
  end
end