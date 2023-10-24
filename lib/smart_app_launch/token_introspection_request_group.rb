require_relative 'token_exchange_test'
require_relative 'token_refresh_body_test'

module SMARTAppLaunch
  class TokenIntrospectionRequestGroup < Inferno::TestGroup
    title 'Token Introspection Request'
    run_as_group

    id :token_introspection_request_group
    description %(
      This group of tests executes the token introspection requests and ensures the correct HTTP response is returned
      but does not validate the contents of the token introspection response. 

      If Inferno cannot reasonably be configured to be authorized to access the token introspectione endpoint, these tests 
      can be skipped.  Instead, an out of band token introspection request must be completed and the response body
      provided as input for the next test group.  
      )

    input :token_endpoint_url, 
          description: 'The complete URL of the token introspection endpoint.'
    
    input :client_id, 
          description: 'ID of the authorization server client requesting introspection'

    input :authorization_required,
          type: 'radio',
          default: 'true',
          description: %(
            Whether or not authorization is required to access the introspection endpoint.  If true, an authorization
            header must be provided. 
          ),
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


    input :authorization_header, 
          optional: true,
          type: 'textarea',
          description: 'Ex: Authorization: Basic czZCaGRSa3F0MzpnWDFmQmF0M2JW'


    test do
      title 'Token introspection endpoint returns a response when provided an active token'
      description %(
      This test will execute a token introspection request for an active token and ensure a 200 status and valid JSON
      body are returned in the response. 

      By default, Inferno will aim to introspect the access token retrieved in the standalone launch tests. However,
      the inputs can be modified and another active access token may be provided.
        
      Per [RFC-7662](https://datatracker.ietf.org/doc/html/rfc7662#section-2), "the definition of an active token is currently dependent upon the authorization
      server, but his is commonly a token that has been issued by this authorization server, is not expired, has not been
      revoked, and is valid for use at the protected resource making the introspection call."
      )
      
      # TODO set default value from other test output
      

      input :standalone_access_token, 
            type: 'textarea',
            description: 'The active access token to be introspected'


      output :token_introspection_response
    end

    test do 
      title 'Token introspection endpoint returns a response when provided an invalid token'
      description %(
        This test will execute a token introspection request for an invalid token and ensure a 200 status and valid JSON
        body are returned in response. 
      )

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