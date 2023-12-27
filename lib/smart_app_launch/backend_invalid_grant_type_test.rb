require_relative 'authorization_request_builder'

module SMARTAppLaunch 
  class BackendServicesInvalidGrantTypeTest < Inferno::Test 
    id :smart_backend_services_invalid_grant_type
    test do
      title 'Authorization request fails when client supplies invalid grant_type'
      description <<~DESCRIPTION
        The Backend Service Authorization specification defines the required fields for the
        authorization request, made via HTTP POST to authorization token endpoint.
        This includes the `grant_type` parameter, where the value must be `client_credentials`.

        The OAuth 2.0 Authorization Framework describes the proper response for an
        invalid request in the client credentials grant flow:

        ```
        If the request failed client authentication or is invalid, the authorization server returns an
        error response as described in [Section 5.2](https://tools.ietf.org/html/rfc6749#section-5.2).
        ```
      DESCRIPTION
      # link 'http://hl7.org/fhir/uv/bulkdata/STU1.0.1/authorization/index.html#protocol-details'

      run do
        post_request_content = AuthorizationRequestBuilder.build(encryption_method: bulk_encryption_method,
                                                                scope: bulk_scope,
                                                                iss: bulk_client_id,
                                                                sub: bulk_client_id,
                                                                aud: smart_token_url,
                                                                grant_type: 'not_a_grant_type',
                                                                kid: bulk_jwks_kid)

        post(**{ client: :token_endpoint }.merge(post_request_content))

        assert_response_status(400)
      end
    end
  end
end