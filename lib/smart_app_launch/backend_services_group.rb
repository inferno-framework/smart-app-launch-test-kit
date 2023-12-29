require_relative 'authorization_request_builder'
require_relative 'backend_invalid_grant_type_test'
require_relative 'backend_invalid_client_assertion_test'
require_relative 'backend_invalid_jwt_test'
require_relative 'backend_auth_request_success_test'
require_relative 'backend_auth_response_body_test'

module SMARTAppLaunch
  class SMARTBackendServices < Inferno::TestGroup
    title 'Backend Services'
    short_description 'Demonstrate SMART Backend Services Authorization'

    id :smart_backend_services

    input :smart_token_url,
          title: 'Backend Services Token Endpoint',
          description: <<~DESCRIPTION
            The OAuth 2.0 Token Endpoint used by the Backend Services specification to provide bearer tokens.
          DESCRIPTION
    input :backend_services_client_id,
          title: 'Backend Services Client ID',
          description: 'Client ID provided at registration to the Inferno application.'
    input :backend_services_requested_scope,
          title: 'Backend Services Requested Scopes',
          description: 'Backend Services Scopes provided at registration to the Inferno application; will be `system/` scopes',
          default: 'system/*.read'
    input :backend_services_encryption_method,
          title: 'Encryption Method',
          description: <<~DESCRIPTION,
            The server is required to suport either ES384 or RS384 encryption methods for JWT signature verification.
            Select which method to use.
          DESCRIPTION
          type: 'radio',
          default: 'ES384',
          options: {
            list_options: [
              {
                label: 'ES384',
                value: 'ES384'
              },
              {
                label: 'RS384',
                value: 'RS384'
              }
            ]
          }
    input :backend_services_jwks_kid,
          title: 'Backend Services JWKS kid',
          description: <<~DESCRIPTION,
            The key ID of the JWKS private key to use for signing the client assertion when fetching an auth token.
            Defaults to the first JWK in the list if no kid is supplied.
          DESCRIPTION
          optional: true
    output :bearer_token

    http_client :token_endpoint do
      url :smart_token_url
    end

    test from: :tls_version_test do
      title 'Authorization service token endpoint secured by transport layer security'
      description <<~DESCRIPTION
        [§170.315(g)(10) Test
        Procedure](https://www.healthit.gov/test-method/standardized-api-patient-and-population-services)
        requires that all exchanges described herein between a client and a
        server SHALL be secured using Transport Layer Security (TLS) Protocol
        Version 1.2 (RFC5246).
      DESCRIPTION
      id :smart_backend_services_token_tls_version

      config(
        inputs: { url: { name: :smart_token_url } },
        options: {  minimum_allowed_version: OpenSSL::SSL::TLS1_2_VERSION }
      )
    end

    test from: :smart_backend_services_invalid_grant_type

    test from: :smart_backend_services_invalid_client_assertion

    test from: :smart_backend_services_invalid_jwt

    test from: :smart_backend_services_auth_request_success

    test from: :smart_backend_services_auth_response_body
  end
end
