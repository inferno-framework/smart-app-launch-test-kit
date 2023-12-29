require_relative 'authorization_request_builder'

module SMARTAppLaunch 
  class BackendServicesAuthorizationRequestSuccessTest < Inferno::Test 
    id :smart_backend_services_auth_request_success
    title 'Authorization request succeeds when supplied correct information'
    description <<~DESCRIPTION
      [The SMART Backend Services IG STU 2.0.0](https://hl7.org/fhir/smart-app-launch/STU2/backend-services.html#issue-access-token)
      states "If the access token request is valid and authorized, the authorization server SHALL issue an access token in response."
    DESCRIPTION

    output :authentication_response

    run do
      post_request_content = AuthorizationRequestBuilder.build(encryption_method: backend_services_encryption_method,
                                                                scope: backend_services_requested_scope,
                                                                iss: backend_services_client_id,
                                                                sub: backend_services_client_id,
                                                                aud: smart_token_url,
                                                                kid: backend_services_jwks_kid)

      authentication_response = post(**{ client: :token_endpoint }.merge(post_request_content))

      assert_response_status([200, 201])

      output authentication_response: authentication_response.response_body
    end
  end
end