require_relative 'token_refresh_test'

module SMARTAppLaunch
  class TokenRefreshSTU2Test < TokenRefreshTest
    include TokenPayloadValidation

    id :smart_token_refresh_stu2
    title 'Server successfully refreshes the access token when optional scope parameter omitted'
    description %(
      Server successfully exchanges refresh token at OAuth token endpoint
      without providing scope in the body of the request.

      Although not required in the token refresh portion of the SMART App
      Launch Guide, the token refresh response should include the HTTP
      Cache-Control response header field with a value of no-store, as well as
      the Pragma response header field with a value of no-cache to be
      consistent with the requirements of the inital access token exchange.
    )

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@86',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@87',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@109'

    input :smart_auth_info, type: :auth_info, options: { mode: 'auth' }

    def add_credentials_to_request(oauth2_headers, oauth2_params)
      if smart_auth_info.asymmetric_auth?
        oauth2_params.merge!(
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          client_assertion: ClientAssertionBuilder.build(
            iss: smart_auth_info.client_id,
            sub: smart_auth_info.client_id,
            aud: smart_auth_info.token_url,
            client_auth_encryption_method: smart_auth_info.encryption_algorithm,
            custom_jwks: smart_auth_info.jwks
          )
        )
      else
        super
      end
    end
  end
end
