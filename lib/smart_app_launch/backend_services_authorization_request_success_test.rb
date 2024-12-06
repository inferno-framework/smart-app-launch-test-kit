require_relative 'backend_services_authorization_request_builder'
require_relative 'backend_services_authorization_group'

module SMARTAppLaunch
  class BackendServicesAuthorizationRequestSuccessTest < Inferno::Test
    id :smart_backend_services_auth_request_success
    title 'Authorization request succeeds when supplied correct information'
    description <<~DESCRIPTION
      The [SMART App Launch 2.0.0 IG specification for Backend Services](https://hl7.org/fhir/smart-app-launch/STU2/backend-services.html#issue-access-token)
      states "If the access token request is valid and authorized, the authorization server SHALL issue an access token in response."
    DESCRIPTION

    input :smart_token_url
    input :auth_info,
          type: :auth_info,
          options: {
            mode: 'auth',
            components: [
              {
                name: :auth_type,
                type: 'select',
                default: 'backend_services',
                locked: 'true'
              }
            ]
          }

    output :authentication_response

    http_client :token_endpoint do
      url :smart_token_url
    end

    run do
      post_request_content = BackendServicesAuthorizationRequestBuilder.build(
        encryption_method: auth_info.encryption_algorithm,
        scope: auth_info.requested_scopes,
        iss: auth_info.client_id,
        sub: auth_info.client_id,
        aud: smart_token_url,
        kid: auth_info.kid
      )

      authentication_response = post(**{ client: :token_endpoint }.merge(post_request_content))

      assert_response_status([200, 201])

      output authentication_response: authentication_response.response_body
    end
  end
end
