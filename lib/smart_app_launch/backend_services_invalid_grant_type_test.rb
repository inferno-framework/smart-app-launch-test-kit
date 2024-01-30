require_relative 'backend_services_authorization_request_builder'

module SMARTAppLaunch 
  class BackendServicesInvalidGrantTypeTest < Inferno::Test 
    id :smart_backend_services_invalid_grant_type
    title 'Authorization request fails when client supplies invalid grant_type'
    description <<~DESCRIPTION
      The [SMART App Launch 2.0.0 IG section on Backend Services](https://hl7.org/fhir/smart-app-launch/STU2/backend-services.html#request-1)
      defines the required fields for the authorization request, made via HTTP POST to authorization 
      token endpoint.
      This includes the `grant_type` parameter, where the value must be `client_credentials`.

      The [OAuth 2.0 Authorization Framework Section 4.3.3](https://datatracker.ietf.org/doc/html/rfc6749#section-4.3.3) 
      describes the proper response for an invalid request in the client credentials grant flow:

      "If the request failed client authentication or is invalid, the authorization server returns an
      error response as described in [Section 5.2](https://tools.ietf.org/html/rfc6749#section-5.2)."
    DESCRIPTION

    input :client_auth_encryption_method, 
          :backend_services_requested_scope, 
          :backend_services_client_id, 
          :smart_token_url, 
          :backend_services_jwks_kid

    # manually input for spec tests, otherwise filled in by output of discovery tests 
    config(
      inputs: {
        token_endpoint: {
          optional: true
        }
      }
    )

    http_client :token_endpoint do
      url :smart_token_url
    end

    run do
      post_request_content = BackendServicesAuthorizationRequestBuilder.build(encryption_method: client_auth_encryption_method,
                                                              scope: backend_services_requested_scope,
                                                              iss: backend_services_client_id,
                                                              sub: backend_services_client_id,
                                                              aud: smart_token_url,
                                                              grant_type: 'not_a_grant_type',
                                                              kid: backend_services_jwks_kid)

      post(**{ client: :token_endpoint }.merge(post_request_content))

      assert_response_status(400)
    end 
  end
end