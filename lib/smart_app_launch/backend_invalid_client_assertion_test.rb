require_relative 'authorization_request_builder'

module SMARTAppLaunch 
  class BackendServicesInvalidClientAssertionTest < Inferno::Test 
    id :smart_backend_services_invalid_client_assertion
    title 'Authorization request fails when supplied invalid client_assertion_type'
    description <<~DESCRIPTION
      The [SMART Backend Services IG STU 2.0.0](https://hl7.org/fhir/smart-app-launch/STU2/backend-services.html#request-1)
      specification defines the required fields for the authorization request, made via HTTP POST to authorization 
      token endpoint.
      This includes the `client_assertion_type` parameter, where the value must be `urn:ietf:params:oauth:client-assertion-type:jwt-bearer`.

      The [OAuth 2.0 Authorization Framework Section 4.3.3](https://datatracker.ietf.org/doc/html/rfc6749#section-4.3.3) 
      describes the proper response for an invalid request in the client credentials grant flow:

      "If the request failed client authentication or is invalid, the authorization server returns an
      error response as described in [Section 5.2](https://tools.ietf.org/html/rfc6749#section-5.2)."
    DESCRIPTION

    run do
      post_request_content = AuthorizationRequestBuilder.build(encryption_method: asymm_conf_client_encryption_method,
                                                                  scope: backend_services_requested_scope,
                                                                  iss: backend_services_client_id,
                                                                  sub: backend_services_client_id,
                                                                  aud: smart_token_url,
                                                                  client_assertion_type: 'not_an_assertion_type',
                                                                  kid: backend_services_jwks_kid)

      post(**{ client: :token_endpoint }.merge(post_request_content))

      assert_response_status(400)
    end 
  end
end