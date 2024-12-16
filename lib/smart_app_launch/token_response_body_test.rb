require_relative 'token_payload_validation'

module SMARTAppLaunch
  class TokenResponseBodyTest < Inferno::Test
    include TokenPayloadValidation

    title 'Token exchange response body contains required information encoded in JSON'
    description %(
      The EHR authorization server shall return a JSON structure that includes
      an access token or a message indicating that the authorization request
      has been denied. `access_token`, `token_type`, and `scope` are required.
      `token_type` must be Bearer. `expires_in` is required for token
      refreshes.

      The format of the optional `fhirContext` field is validated if present.
    )
    id :smart_token_response_body

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

    run do
      skip_if request.status != 200, 'Token exchange was unsuccessful'

      assert_valid_json(request.response_body)
      token_response_body = JSON.parse(request.response_body)

      smart_auth_info.refresh_token = token_response_body['refresh_token']
      smart_auth_info.access_token = token_response_body['access_token']
      smart_auth_info.expires_in = token_response_body['expires_in']

      output id_token: token_response_body['id_token'],
             refresh_token: token_response_body['refresh_token'],
             access_token: token_response_body['access_token'],
             expires_in: token_response_body['expires_in'],
             patient_id: token_response_body['patient'],
             encounter_id: token_response_body['encounter'],
             received_scopes: token_response_body['scope'],
             intent: token_response_body['intent'],
             smart_auth_info: smart_auth_info

      validate_required_fields_present(token_response_body, ['access_token', 'token_type', 'expires_in', 'scope'])
      validate_token_field_types(token_response_body)
      validate_token_type(token_response_body)
      unless config.options[:ignore_missing_scopes_check]
        check_for_missing_scopes(smart_auth_info.requested_scopes,
                                 token_response_body)
      end

      assert access_token.present?, 'Token response did not contain an access token'
      assert token_response_body['token_type']&.casecmp('Bearer')&.zero?,
             '`token_type` field must have a value of `Bearer`'

      validate_fhir_context(token_response_body['fhirContext'])
    end
  end
end
