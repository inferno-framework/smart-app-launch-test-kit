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

        It is not possible to know what the expected value for `exp` is in advance, so Inferno tests that the claim is
        present and represents a time greater than or equal to 10 minutes in the past. 

        Conditionally Required:
        * IF launch context parameter(s) included in access token, introspection response includes claim(s) for 
        launch context parameter(s) 
          * Parameters checked for are `patient` and `encounter`
        * IF identity token was included as part of access token response, `iss` and `sub` claims are present in the
        introspection response and match those of the orignal ID token

        Optional but Recommended:
        * IF identity token was included as part of access token response, `fhirUser` claim SHOULD be present in 
        introspection response and should match the claim in the ID token
      )

      input :standalone_client_id,
            title: 'Access Token client_id',
            description: 'ID of the client that requested the access token being introspected'


      input :standalone_received_scopes,
            title: 'Expected Introspection Response Value: scope',
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

      def assert_introspection_response_match(json_response, claim_key, expected_value)
        puts "Claim value: #{json_response[claim_key]}"
        expected_value = expected_value.strip
        claim_value = json_response[claim_key]
        assert claim_value != nil, "Failure: introspection response has no claim for '#{claim_key}'"
        claim_value = claim_value.strip
        puts "Expected value: #{expected_value}"
        puts "expected_string is_a string? #{expected_value.is_a?(String)}"
        puts "claim_string is_a string? #{claim_value.is_a?(String)}"
        puts "expected_string encoding: #{expected_value.encoding}"
        puts "claim_string encoding: #{claim_value.encoding}"
        puts "Eql? #{claim_value.eql?(expected_value)}"
        puts "Spaceship comparsion: #{expected_value <=> claim_value}"
        assert claim_value.eql?(expected_value), 
            "Failure: expected introspection response value for '#{claim_key}' to match expected value '#{expected_value}'"
      end

      run do
        assert_valid_json(active_token_introspection_response_body)
        active_introspection_response_body_parsed = JSON.parse(active_token_introspection_response_body)

        # Required Fields
        assert active_introspection_response_body_parsed['active'] == true, "Failure: expected introspection response for 'active' to be true for valid token"
        assert_introspection_response_match(active_introspection_response_body_parsed, 'client_id', standalone_client_id)
        assert_introspection_response_match(active_introspection_response_body_parsed, 'scope', standalone_received_scopes)

        # exp field 
        exp = active_introspection_response_body_parsed['exp']
        assert exp != nil, "Failure: introspection response has no claim for required field 'exp'"
        current_time = Time.now.to_i 
        # Ensure token exp time is within at least 10 minutes of the past
        assert exp.to_i >= current_time - 6000, "Failure: expired token - exp claim of #{exp} for active token is more than 10 minutes in the past"
        
        # Conditional fields
        if standalone_patient_id.present?
          puts "Standalone_patient_id present, value: #{standalone_patient_id}"
          assert_introspection_response_match(active_introspection_response_body_parsed, 'patient', standalone_patient_id)
        end
        
        if standalone_encounter_id.present?
          assert_introspection_response_match(active_introspection_response_body_parsed, 'encounter', standalone_encounter_id)
        end
        # assert active_introspection_response_body_parsed['patient'].strip == standalone_patient_id.strip, "Expected patient context: #{standalone_patient_id}" if standalone_patient_id.present?
        # assert active_introspection_response_body_parsed['encounter'].strip == standalone_encounter_id.strip, "Expected patient context: #{standalone_encounter_id}" if standalone_encounter_id.present?

        # ID Token Fields
        if standalone_id_token.present?
          # parse
          id_payload, id_header =
          JWT.decode(
            standalone_id_token,
            nil,
            false
          )
          puts "ID token payload: #{id_payload}"
          puts "ID token header: #{id_header}"
          id_token_iss = id_payload['iss']
          id_token_sub = id_payload['sub']
          assert id_token_iss != nil, "Failure: ID token from access token response does not have 'iss' claim"
          assert id_token_sub != nil, "Failure: ID token from access token response does not have 'sub' claim"
          assert_introspection_response_match(active_introspection_response_body_parsed, 'iss', id_token_iss)
          assert_introspection_response_match(active_introspection_response_body_parsed, 'sub', id_token_sub)

          fhirUser_id_claim = id_payload['fhirUser']
          # TODO issue warning if not present or if introspection response does not have claim for fhirUser
          fhirUser_intr_claim = active_introspection_response_body_parsed['fhirUser']

          puts "About to enter info do section"
          info do 
            puts "Running info assertion, fhirUser_id_claim != nil = #{fhirUser_id_claim != nil}, fhirUser_intr_claim eq? fhirUser_id_claim = #{fhirUser_intr_claim.eql?(fhirUser_id_claim)}"
            puts "fhirUser_id_claim = #{fhirUser_id_claim}, fhirUser_intr_claim = #{fhirUser_intr_claim}"
            assert fhirUser_intr_claim.eql?(fhirUser_id_claim), "Introspection response SHOULD include fhirUser claim because ID token included in original access response" if fhirUser_id_claim != nil
            puts "Finished running assertion"
          end
          puts "Now at end of ID token section"
        end
      end

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

      run do
        assert_valid_json(invalid_token_introspection_response_body)
        invalid_token_introspection_response_body_parsed = JSON.parse(invalid_token_introspection_response_body)
        assert invalid_token_introspection_response_body_parsed['active'] == false, "Failure: expected introspection response for 'active' to be false for invalid token"
        assert invalid_token_introspection_response_body_parsed.size == 1, "Failure: expected only 'active' field to be present in introspection response for invalid token"

      end
    end
  end
end