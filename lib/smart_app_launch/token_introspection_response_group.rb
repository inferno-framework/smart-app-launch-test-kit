require_relative 'token_introspection_request_group'

module SMARTAppLaunch
  class TokenIntrospectionResponseGroup < Inferno::TestGroup
    title 'Token Introspection Response'
    run_as_group

    id :token_introspection_response_group
    description %(
      This group of tests validates the contents of the token introspection response.  The inputs will default to the outputs
      of the Standalone Launch test and/or Token Introspection Request tests if they were run; otherwise, input values
      will need to be manually entered. 
      )
      
    test do 
      title 'Token introspection response for an active token contains required fields'
    end

    test do
      title 'Token introspection response for an invalid token contains required fields'
    end
  end
end