require_relative 'token_introspection_request_group'

module SMARTAppLaunch
  class TokenIntrospectionResponseGroup < Inferno::TestGroup
    title 'Token Introspection Response'
    run_as_group

    id :token_introspection_response_group
    description %(
      This group of tests validates the contents of the token introspection response by comparing the fields and/or 
      values in the token introspection response to the fields and/or values of the original access token response 
      in which the access token was given to the client.   
      )

      input_instructions %(
        There are two categories of input for this test group: 

        1. The access token response values, which will dictate what the tests will expect to find in the token 
        introspection response.  If the Token Introspection Request test group was run AND the option to introspect
        the access token from the Standalone Launch tests was selected, these values will auto-fill; otherwise,
        the tester will need to run an out-of-band ACCESS TOKEN request and manually input the access token response
        parameters.   
        
        2. The token introspection response bodies. If the Token Introspection Request test group was run, these will
        auto-fill; otherwise, the tester will need to an run out-of-band INTROSPECTION requests for:

          a. The ACTIVE access token received from the out-of-band access token request, AND

          b. An INACTIVE OR INVALID token 

        The client making both introspection requests must be authorized to access the introspection endpoint if
        the endpoint is protected.
      )
      
    test do 
      title 'Token introspection response for an active token contains required fields'

      description %(
        This test will check whether the metadata in the token introspection response is correct for an active token and
         that the response data matches the data in the original access token and/or access token response from the 
         authorization server, including the following:
      
        Required:
        *  `active` claim is set to true 
        * `scope`, `client_id`, and `exp` claim(s) match between introspection response and access token

        Conditionally Required:
        * IF launch context parameter(s) included in access token, introspection response includes claim(s) for 
        launch context parameter(s) 
          * Parameters checked for are `patient` and `encounter`
        * IF identity token was included as part of access token response, `iss` and `sub` claims are present in 
        introspection response

        Optional but Recommended:
        * IF identity token was included as part of access token response, `fhirUser` claim SHOULD be present in 
        introspection response
      )

      input :access_token_response_client_id,
            description: 'The client ID from the original access token response body'
      
      input :access_token_response_expires_in,
            description: 'The expires_in value from the original access token response body'

      input :access_token_response_scopes,
            description: 'A space-separated list of scopes from the original access token response body'
      
      input :access_token_response_id_token,
            type: 'textarea',
            optional: true,
            description: 'The ID token from the original access token response body, IF it was present'

      input :access_token_response_patient,
            optional: true,
            description: 'The value for patient context from the original access token response body, IF it was present'

      input :access_token_response_encounter,
            optional: true,
            description: 'The value for encounter context from the original access token response body, IF it was present'

      input :active_token_introspection_response_body,
            type: 'textarea',
            description: 'The JSON body of the token introspection response when provided an ACTIVE token'

    end

    test do
      title 'Token introspection response for an invalid token contains required fields'

      description %(
        From [RFC7662 OAuth2.0 Token Introspection](https://datatracker.ietf.org/doc/html/rfc7662#section-2.2):
        "If the introspection call is properly authorized but the token is not
        active, does not exist on this server, or the protected resource is
        not allowed to introspect this particular token, then the
        authorization server MUST return an introspection response with the
        "active" field set to "false".  Note that to avoid disclosing too
        much of the authorization server's state to a third party, the
        authorization server SHOULD NOT include any additional information
        about an inactive token, including why the token is inactive."
      )

      input :inactive_token_introspection_response_body,
            type: 'textarea',
            description: 'The JSON body of the token introspection response when provided an INVALID or INACTIVE token'
    end
  end
end