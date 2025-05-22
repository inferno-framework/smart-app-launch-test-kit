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

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@253'

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

    output :authentication_response, :smart_auth_info

    run do
      post_request_content = BackendServicesAuthorizationRequestBuilder.build(
        encryption_method: smart_auth_info.encryption_algorithm,
        scope: smart_auth_info.requested_scopes,
        iss: smart_auth_info.client_id,
        sub: smart_auth_info.client_id,
        aud: smart_auth_info.token_url,
        kid: smart_auth_info.kid,
        custom_jwks: smart_auth_info.jwks
      )

      authentication_response = post(smart_auth_info.token_url, **post_request_content)

      assert_response_status([200, 201])

      smart_auth_info.issue_time = Time.now

      output authentication_response: authentication_response.response_body,
             smart_auth_info: smart_auth_info
    end
  end
end
