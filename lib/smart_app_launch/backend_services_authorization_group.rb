require_relative 'backend_services_authorization_request_builder'
require_relative 'backend_services_invalid_grant_type_test'
require_relative 'backend_services_invalid_client_assertion_test'
require_relative 'backend_services_invalid_jwt_test'
require_relative 'backend_services_authorization_request_success_test'
require_relative 'backend_services_authorization_response_body_test'
require_relative 'token_exchange_stu2_test'

module SMARTAppLaunch
  class BackendServicesAuthorizationGroup < Inferno::TestGroup
    title 'SMART Backend Services Authorization'
    short_description 'Demonstrate SMART Backend Services Authorization'

    id :backend_services_authorization
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@318'

    input :smart_auth_info,
          title: 'Backend Services Credentials',
          type: :auth_info,
          options: {
            mode: 'auth',
            components: [
              {
                name: :auth_type,
                default: 'backend_services',
                locked: 'true'
              },
              {
                name: :use_discovery,
                locked: true
              }
            ]
          }

    test from: :smart_tls,
         id: :smart_backend_services_token_tls_version,
         title: 'Authorization service token endpoint secured by transport layer security',
         description: <<~DESCRIPTION,
           The [SMART App Launch 2.0.0 IG specification for Backend Services](https://hl7.org/fhir/smart-app-launch/STU2/backend-services.html#request-1)
           states "the client SHALL use the Transport Layer Security (TLS) Protocol Version 1.2 (RFC5246)
           or a more recent version of TLS to authenticate the identity of the FHIR authorization server and to
           establish an encrypted, integrity-protected link for securing all exchanges between the client and the
           FHIR authorization server’s token endpoint. All exchanges described herein between the client and the
           FHIR server SHALL be secured using TLS V1.2 or a more recent version of TLS."
         DESCRIPTION
         config: {
           options: {
             minimum_allowed_version: OpenSSL::SSL::TLS1_2_VERSION,
             smart_endpoint_key: :token_url
           }
         }

    test from: :smart_backend_services_invalid_grant_type

    test from: :smart_backend_services_invalid_client_assertion

    test from: :smart_backend_services_invalid_jwt

    test from: :smart_backend_services_auth_request_success

    test from: :smart_backend_services_auth_response_body
  end
end
