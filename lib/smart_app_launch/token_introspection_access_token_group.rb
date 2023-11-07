require_relative 'standalone_launch_group_stu2'

module SMARTAppLaunch
  class TokenIntrospectionAccessTokenGroup < Inferno::TestGroup
    title 'Receive Access Token to Introspect'
    run_as_group

    id :token_introspection_access_token_group
    
    group from: :smart_standalone_launch_stu2
  end
end