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

    input :client_auth_type
    input :client_auth_encryption_method, optional: true
    input :client_secret, optional: true

    def add_credentials_to_request(oauth2_headers, oauth2_params)
      case client_auth_type
      when 'public'
        oauth2_params['client_id'] = client_id
      when 'confidential_symmetric'
        assert client_secret.present?,
               "A client secret must be provided when using confidential symmetric client authentication."

        credentials = Base64.strict_encode64("#{client_id}:#{client_secret}")
        oauth2_headers['Authorization'] = "Basic #{credentials}"
      when 'confidential_asymmetric'
        oauth2_params.merge!(
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          client_assertion: ClientAssertionBuilder.build(
            iss: client_id,
            sub: client_id,
            aud: smart_token_url,
            client_auth_encryption_method: client_auth_encryption_method
          )
        )
      end
    end
  end
end
