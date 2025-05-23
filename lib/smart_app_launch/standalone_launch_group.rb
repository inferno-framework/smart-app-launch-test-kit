require_relative 'app_redirect_test'
require_relative 'code_received_test'
require_relative 'smart_tls_test'
require_relative 'token_exchange_test'
require_relative 'token_response_body_test'
require_relative 'token_response_headers_test'

module SMARTAppLaunch
  class StandaloneLaunchGroup < Inferno::TestGroup
    id :smart_standalone_launch
    title 'SMART Standalone Launch'
    short_description 'Demonstrate the ability to authorize an app using the Standalone Launch.'

    description %(
      # Background

      The [Standalone
      Launch Sequence](https://www.hl7.org/fhir/smart-app-launch/1.0.0/index.html#standalone-launch-sequence)
      allows an app, like Inferno, to be launched independent of an
      existing EHR session. It is one of the two launch methods described in
      the SMART App Launch Framework alongside EHR Launch. The app will
      request authorization for the provided scope from the authorization
      endpoint, ultimately receiving an authorization token which can be used
      to gain access to resources on the FHIR server.

      # Test Methodology

      Inferno will redirect the user to the the authorization endpoint so that
      they may provide any required credentials and authorize the application.
      Upon successful authorization, Inferno will exchange the authorization
      code provided for an access token.

      For more information on the #{title}:

      * [Standalone Launch Sequence](https://www.hl7.org/fhir/smart-app-launch/1.0.0/index.html#standalone-launch-sequence)
    )

    config(
      inputs: {
        smart_auth_info: {
          name: :standalone_smart_auth_info,
          title: 'Standalone Launch Credentials',
          options: {
            components: [
              {
                name: :auth_type,
                options: {
                  list_options: [
                    { label: 'Public', value: 'public' },
                    { label: 'Confidential Symmetric', value: 'symmetric' }
                  ]
                }
              },
              {
                name: :requested_scopes,
                default: 'launch/patient openid fhirUser offline_access patient/*.read'
              },
              {
                name: :use_discovery,
                locked: true
              },
              {
                name: :auth_request_method,
                default: 'GET',
                locked: true
              },
              {
                name: :pkce_support,
                default: 'disabled'
              }
            ]
          }
        },
        url: {
          title: 'Standalone FHIR Endpoint',
          description: 'URL of the FHIR endpoint used by standalone applications'
        },
        code: {
          name: :standalone_code
        },
        state: {
          name: :standalone_state
        },
        smart_credentials: {
          name: :standalone_smart_credentials
        }
      },
      outputs: {
        code: { name: :standalone_code },
        token_retrieval_time: { name: :standalone_token_retrieval_time },
        state: { name: :standalone_state },
        id_token: { name: :standalone_id_token },
        refresh_token: { name: :standalone_refresh_token },
        access_token: { name: :standalone_access_token },
        expires_in: { name: :standalone_expires_in },
        patient_id: { name: :standalone_patient_id },
        encounter_id: { name: :standalone_encounter_id },
        received_scopes: { name: :standalone_received_scopes },
        intent: { name: :standalone_intent },
        smart_credentials: { name: :standalone_smart_credentials },
        smart_auth_info: { name: :standalone_smart_auth_info }
      },
      requests: {
        redirect: { name: :standalone_redirect },
        token: { name: :standalone_token }
      }
    )

    test from: :smart_tls,
         id: :standalone_auth_tls,
         title: 'OAuth 2.0 authorize endpoint secured by transport layer security',
         description: %(
           Apps MUST assure that sensitive information (authentication secrets,
           authorization codes, tokens) is transmitted ONLY to authenticated
           servers, over TLS-secured channels.
         ),
         config: {
           options: {
             minimum_allowed_version: OpenSSL::SSL::TLS1_2_VERSION,
             smart_endpoint_key: :auth_url
           }
         }
    test from: :smart_app_redirect
    test from: :smart_code_received
    test from: :smart_tls,
         id: :standalone_token_tls,
         title: 'OAuth 2.0 token endpoint secured by transport layer security',
         description: %(
           Apps MUST assure that sensitive information (authentication secrets,
           authorization codes, tokens) is transmitted ONLY to authenticated
           servers, over TLS-secured channels.
         ),
         config: {
           options: {
             minimum_allowed_version: OpenSSL::SSL::TLS1_2_VERSION,
             smart_endpoint_key: :token_url
           }
         }
    test from: :smart_token_exchange
    test from: :smart_token_response_body
    test from: :smart_token_response_headers
  end
end
