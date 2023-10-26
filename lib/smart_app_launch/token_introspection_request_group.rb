require_relative 'token_exchange_test'
require_relative 'token_refresh_body_test'
require_relative 'well_known_endpoint_test'
require_relative 'standalone_launch_group'

module SMARTAppLaunch
  class TokenIntrospectionRequestGroup < Inferno::TestGroup
    title 'Token Introspection Request'
    run_as_group

    id :token_introspection_request_group
    description %(
      This group of tests executes the token introspection requests and ensures the correct HTTP response is returned
      but does not validate the contents of the token introspection response. 

      If Inferno cannot reasonably be configured to be authorized to access the token introspection endpoint, these tests 
      can be skipped.  Instead, an out-of-band token introspection request must be completed and the response body
      manually provided as input for the Token Introspection Response test group.
      )

    input_instructions %(
      By default, Inferno will aim to introspect the access token retrieved in the standalone launch tests. However,
      the inputs can be modified and another active access token may be provided.  Either way, the token must be in an
      active state in order for the test to pass.
        
      Per [RFC-7662](https://datatracker.ietf.org/doc/html/rfc7662#section-2), "the definition of an active token is currently dependent upon the authorization
      server, but this is commonly a token that has been issued by this authorization server, is not expired, has not been
      revoked, and is valid for use at the protected resource making the introspection call."

      If only a client ID is input, Inferno will assume this is a public client and not include an Authorization
      header in the introspection request.  If a client ID and secret are provided, Inferno will default to 
      an Authorization: Basic header.  For all other use cases, tester must provide their own authorization header
      for the HTTP request.  
    )

    input :well_known_introspection_url, 
          title: 'Token Introspection Endpoint URL', 
          description: 'The complete URL of the token introspection endpoint.'
    
    input :standalone_client_id, 
          title: 'Client ID',
          optional: true,
          description: %(
            ID of the client requesting introspection, as it is registered with the authorization server.
            Defaults to Standalone Client ID, if provided.
          )

    input :standalone_client_secret,
          title: 'Client Secret',
          optional: true,
          description: %(
            Provide to use Authorization: Basic header in introspection request.
          )

    input :custom_auth_method,
          title: 'Use Custom HTTP Authorization Header',
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'True',
                value: 'true'
              },
              {
                label: 'False',
                value: 'false'
              }
            ]
          }

    input :custom_authorization_header,
          title: 'Custom HTTP Authorization Header for Introspection Request',
          type: 'textarea',
          optional: true,
          description: %(
            Include both header name and value.
            Ex: 'Authorization: Bearer 23410913-abewfq.123483' 
            )

    test do
      title 'Token introspection endpoint returns a response when provided an active token'
      description %(
      This test will execute a token introspection request for an active token and ensure a 200 status and valid JSON
      body are returned in the response. 
      )
      
 

      input :standalone_access_token, 
            title: 'Access Token',
            description: 'The access token to be introspected.'


      output :active_token_introspection_response_body
    
    end

    test do 
      title 'Token introspection endpoint returns a response when provided an invalid token'
      description %(
        This test will execute a token introspection request for an invalid token and ensure a 200 status and valid JSON
        body are returned in response. 
      )

      output :inactive_token_introspection_response_body
      run do
        # headers = {'Accept' => 'application/json', 'Content-Type' => 'application/x-www-form-urlencoded'}
        # body = "token=invalid_token_value"
        # headers, body = add_credentials(headers, body, client_id, client_secret)
        # post(token_introspection_endpoint, body: body, headers: headers)
        
        # assert_response_status(200)
        # assert_valid_json(request.response_body)
        # introspection_response_body = JSON.parse(request.response_body)
        # assert introspection_response_body['active'] == false, "Failure: expected introspection response for 'active' to be false for invalid token"
        # assert introspection_response_body.size == 1, "Failure: expected only 'active' field to be present in introspection response for invalid token"
      end
    end
  end
end