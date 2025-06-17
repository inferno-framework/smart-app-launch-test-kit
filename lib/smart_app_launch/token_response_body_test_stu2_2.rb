require_relative 'token_payload_validation'

module SMARTAppLaunch
  class TokenResponseBodyTestSTU22 < TokenResponseBodyTest
    title 'Token exchange response body contains required information encoded in JSON'
    description %(
      The EHR authorization server shall return a JSON structure that includes
      an access token or a message indicating that the authorization request
      has been denied. `access_token`, `token_type`, and `scope` are required.
      `token_type` must be Bearer. `expires_in` is required for token
      refreshes.

      The format of the optional `fhirContext` field is validated if present.
    )

    id :smart_token_response_body_stu2_2
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@73',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@74',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@75',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@78',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@84',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@172'

    input :smart_auth_info, type: :auth_info, options: { mode: 'auth' }
    output :id_token,
           :refresh_token,
           :access_token,
           :expires_in,
           :patient_id,
           :encounter_id,
           :received_scopes,
           :intent,
           :smart_auth_info
    uses_request :token

    def validate_fhir_context(fhir_context)
      validate_fhir_context_stu2_2(fhir_context)
    end
  end
end
