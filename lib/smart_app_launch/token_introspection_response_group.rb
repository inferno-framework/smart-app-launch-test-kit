require_relative 'token_introspection_request_group'
require_relative 'token_exchange_test'

module SMARTAppLaunch
  class TokenIntrospectionResponseGroup < Inferno::TestGroup
    title 'Validate Token Introspection Response'
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
        introspection response.  If the Request New Access Token group was run, these inputs will auto-populate.   
        
        2. The token introspection response bodies. If the Issue Introspection Request test group was run, these will
        auto-populate; otherwise, the tester will need to an run out-of-band INTROSPECTION requests for a. An ACTIVE 
        access token, AND b. An INACTIVE OR INVALID token 

        See [RFC-7662](https://datatracker.ietf.org/doc/html/rfc7662#section-2) for details on active vs inactive tokens.
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

      input :standalone_client_id,
            title: 'Access Token client_id',
            description: 'ID of the client that requested the access token being introspected'


      input :standalone_received_scopes,
            title: 'Expected Introspection Response Value: scopes',
            description: 'A space-separated list of scopes from the original access token response body'
      
      input :standalone_id_token,
            title: 'Access Token Response: id_token',
            type: 'textarea',
            optional: true,
            description: 'The ID token from the original access token response body, IF it was present'

      input :standalone_patient_id,
            title: 'Expected Introspection Response for Patient Launch Context Paramter',
            optional: true,
            description: 'The value for patient launch context from the original access token response body, IF it was present'

      input :standalone_encounter_id,
            title: 'Expected Introspection Response for Encounter Launch Context Parameter',
            optional: true,
            description: 'The value for encounter launch context from the original access token response body, IF it was present'

      input :active_token_introspection_response_body,
            title: 'Active Token Introspection Response Body',
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

      input :invalid_token_introspection_response_body,
            title: 'Invalid Token Introspection Response Body',
            type: 'textarea',
            description: 'The JSON body of the token introspection response when provided an INVALID token'
    end
  end
end