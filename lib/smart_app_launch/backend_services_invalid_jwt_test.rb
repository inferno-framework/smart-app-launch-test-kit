require_relative 'backend_services_authorization_request_builder'

module SMARTAppLaunch
  class BackendServicesInvalidJWTTest < Inferno::Test
    id :smart_backend_services_invalid_jwt
    title 'Authorization request fails when client supplies invalid JWT token'
    description <<~DESCRIPTION
      The [SMART App Launch 2.0.0 IG section on Backend Services](https://hl7.org/fhir/smart-app-launch/STU2/backend-services.html#request-1)
      defines the required fields for the authorization request, made via HTTP POST to authorization
      token endpoint.
      This includes the `client_assertion` parameter, where the value must be
      a valid JWT as specified in
      [Asymmetric (public key) Client Authentication](https://hl7.org/fhir/smart-app-launch/STU2/client-confidential-asymmetric.html#authenticating-to-the-token-endpoint)
      The JWT SHALL include the following claims, and SHALL be signed with the client’s private key.

      | JWT Claim | Required? | Description |
      | --- | --- | --- |
      | `iss` | required | Issuer of the JWT -- the client's `client_id`, as determined during registration with the FHIR authorization server (note that this is the same as the value for the sub claim) |
      | `sub` | required | The service's `client_id`, as determined during registration with the FHIR authorization server (note that this is the same as the value for the `iss` claim) |
      | `aud` | required | The FHIR authorization server's "token URL" (the same URL to which this authentication JWT will be posted) |
      | `exp` | required | Expiration time integer for this authentication JWT, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC). This time SHALL be no more than five minutes in the future. |
      | `jti` | required | A nonce string value that uniquely identifies this authentication JWT. |

      The [OAuth 2.0 Authorization Framework Section 4.3.3](https://datatracker.ietf.org/doc/html/rfc6749#section-4.3.3)
      describes the proper response for an invalid request in the client credentials grant flow:

      "If the request failed client authentication or is invalid, the authorization server returns an
      error response as described in [Section 5.2](https://tools.ietf.org/html/rfc6749#section-5.2)."
    DESCRIPTION

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@238',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@327',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@328',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@329',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@330',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@332',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@340'

    input :smart_auth_info,
          type: :auth_info,
          options: {
            mode: 'auth',
            components: [
              {
                name: :auth_type,
                default: 'backend_services',
                locked: 'true'
              }
            ]
          }

    run do
      post_request_content = BackendServicesAuthorizationRequestBuilder.build(
        encryption_method: smart_auth_info.encryption_algorithm,
        scope: smart_auth_info.requested_scopes,
        iss: smart_auth_info.client_id,
        sub: smart_auth_info.client_id,
        aud: smart_auth_info.token_url,
        client_assertion_type: 'not_an_assertion_type',
        kid: smart_auth_info.kid,
        custom_jwks: smart_auth_info.jwks
      )

      post(smart_auth_info.token_url, **post_request_content)

      assert_response_status([400, 401])
    end
  end
end
