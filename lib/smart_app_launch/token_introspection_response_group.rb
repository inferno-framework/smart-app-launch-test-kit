require_relative 'token_introspection_request_group'
require_relative 'token_exchange_test'

module SMARTAppLaunch
  class SMARTTokenIntrospectionResponseGroup < Inferno::TestGroup
    title 'Validate Token Introspection Response'
    run_as_group

    id :smart_token_introspection_response_group
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
        * `active` claim is set to true
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

      input :standalone_smart_auth_info, type: :auth_info, options: { mode: 'auth' }

      input :standalone_received_scopes,
            title: 'Expected Introspection Response Value: scope',
            description: 'A space-separated list of scopes from the original access token response body'

      input :standalone_id_token,
            title: 'Access Token Response: id_token',
            type: 'textarea',
            optional: true,
            description: 'The ID token from the original access token response body, IF it was present'

      input :standalone_patient_id,
            title: 'Expected Introspection Response for Patient Launch Context Parameter',
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

      def get_json_claim_value(json_response, claim_key)
        claim_value = json_response[claim_key]
        assert !claim_value.nil?, "Failure: introspection response has no claim for '#{claim_key}'"
        claim_value
      end

      def assert_introspection_response_match(json_response, claim_key, expected_value)
        expected_value = expected_value.strip
        claim_value = get_json_claim_value(json_response, claim_key)
        claim_value = claim_value.strip
        assert claim_value.eql?(expected_value),
               "Failure: expected introspection response value for '#{claim_key}' to match expected value '#{expected_value}'"
      end

      run do
        skip_if active_token_introspection_response_body.nil?, 'No introspection response available to validate.'
        assert_valid_json(active_token_introspection_response_body)
        active_introspection_response_body_parsed = JSON.parse(active_token_introspection_response_body)

        # Required Fields
        assert active_introspection_response_body_parsed['active'] == true,
               "Failure: expected introspection response for 'active' to be Boolean value true for valid token"
        assert_introspection_response_match(active_introspection_response_body_parsed, 'client_id',
                                            standalone_smart_auth_info.client_id)

        response_scope_value = get_json_claim_value(active_introspection_response_body_parsed, 'scope')

        # splitting contents and comparing values allows a scope lists with the same contents but different orders to still pass
        response_scopes_split = response_scope_value.split
        expected_scopes_split = standalone_received_scopes.split

        assert response_scopes_split.length == expected_scopes_split.length,
               "Failure: number of scopes in introspection response, #{response_scopes_split.length}, does not match number of scopes in access token response, #{expected_scopes_split.length}"

        expected_scopes_split.each do |scope|
          assert response_scopes_split.include?(scope),
                 "Failure: expected scope '#{scope}' not present in introspection response scopes"
        end

        # Cannot verify exact value for exp, so instead ensure its value represents a time >= 10 minutes in the past
        exp = active_introspection_response_body_parsed['exp']
        assert !exp.nil?, "Failure: introspection response has no claim for 'exp'"
        current_time = Time.now.to_i
        assert exp.to_i >= current_time - 600,
               "Failure: expired token, exp claim of #{exp} for active token is more than 10 minutes in the past"

        # Conditional fields
        if standalone_patient_id.present?
          assert_introspection_response_match(active_introspection_response_body_parsed, 'patient',
                                              standalone_patient_id)
        end
        if standalone_encounter_id.present?
          assert_introspection_response_match(active_introspection_response_body_parsed, 'encounter',
                                              standalone_encounter_id)
        end

        # ID Token Fields
        if standalone_id_token.present?
          id_payload, =
            JWT.decode(
              standalone_id_token,
              nil,
              false
            )

          # Required fields if ID token present
          id_token_iss = id_payload['iss']
          id_token_sub = id_payload['sub']

          assert !id_token_iss.nil?, "Failure: ID token from access token response does not have 'iss' claim"
          assert !id_token_sub.nil?, "Failure: ID token from access token response does not have 'sub' claim"
          assert_introspection_response_match(active_introspection_response_body_parsed, 'iss', id_token_iss)
          assert_introspection_response_match(active_introspection_response_body_parsed, 'sub', id_token_sub)

          # fhirUser not required but recommended
          fhirUser_id_claim = id_payload['fhirUser']
          fhirUser_intr_claim = active_introspection_response_body_parsed['fhirUser']

          info do
            unless fhirUser_id_claim.nil?
              assert !fhirUser_intr_claim.nil?,
                     'Introspection response SHOULD include claim for fhirUser because ID token present in access token response'
            end
            unless fhirUser_id_claim.nil?
              assert fhirUser_intr_claim.eql?(fhirUser_id_claim),
                     'Introspection response claim for fhirUser SHOULD match value in ID token'
            end
          end
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
        skip_if invalid_token_introspection_response_body.nil?,
                'No invalid introspection response available to validate.'
        assert_valid_json(invalid_token_introspection_response_body)
        invalid_token_introspection_response_body_parsed = JSON.parse(invalid_token_introspection_response_body)
        assert invalid_token_introspection_response_body_parsed['active'] == false,
               "Failure: expected introspection response for 'active' to be Boolean value false for invalid token"
        assert invalid_token_introspection_response_body_parsed.size == 1,
               "Failure: expected only 'active' field to be present in introspection response for invalid token"
      end
    end
  end
end
