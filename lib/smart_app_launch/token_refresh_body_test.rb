require_relative 'token_payload_validation'

module SMARTAppLaunch
  class TokenRefreshBodyTest < Inferno::Test
    include TokenPayloadValidation

    id :smart_token_refresh_body
    title 'Token refresh response contains all required fields'
    description %(
      The EHR authorization server SHALL return a JSON structure that includes
      an access token or a message indicating that the authorization request
      has been denied. `access_token`, `expires_in`, `token_type`, and `scope` are
      required. `access_token` must be `Bearer`.

      Scopes returned must be a strict subset of the scopes granted in the original launch.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@110',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@111',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@112',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@113',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@114'

    input :received_scopes
    input :smart_auth_info, type: :auth_info, options: { mode: 'auth' }
    output :refresh_token, :access_token, :token_retrieval_time, :expires_in, :received_scopes, :smart_auth_info
    uses_request :token_refresh

    run do
      skip_if request.status != 200, 'Token exchange was unsuccessful'

      assert_valid_json(response[:body])

      body = JSON.parse(response[:body])
      output refresh_token: body['refresh_token'] if body.key? 'refresh_token'
      smart_auth_info.refresh_token = refresh_token if refresh_token.present?

      required_fields = ['access_token', 'token_type', 'expires_in', 'scope']
      validate_required_fields_present(body, required_fields)

      old_received_scopes = received_scopes
      smart_auth_info.issue_time = Time.now
      output access_token: body['access_token'],
             token_retrieval_time: smart_auth_info.issue_time.iso8601,
             expires_in: body['expires_in'],
             received_scopes: body['scope']

      smart_auth_info.access_token = access_token
      smart_auth_info.expires_in = expires_in
      output smart_auth_info: smart_auth_info

      validate_token_field_types(body)
      validate_token_type(body)

      validate_scope_subset(received_scopes, old_received_scopes)
    end
  end
end
