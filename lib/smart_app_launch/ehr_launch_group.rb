require_relative 'app_launch_test'
require_relative 'app_redirect_test'
require_relative 'code_received_test'
require_relative 'launch_received_test'
require_relative 'token_exchange_test'
require_relative 'token_response_body_test'
require_relative 'token_response_headers_test'

module SMARTAppLaunch
  class EHRLaunchGroup < Inferno::TestGroup
    id :smart_ehr_launch
    title 'SMART EHR Launch'
    short_description 'Demonstrate the ability to authorize an app using the EHR Launch.'

    description %(
      # Background

      The [EHR
      Launch](https://www.hl7.org/fhir/smart-app-launch/1.0.0/index.html#ehr-launch-sequence)
      is one of two ways in which an app can be launched, the other being
      Standalone launch. In an EHR launch, the app is launched from an
      existing EHR session or portal by a redirect to the registered launch
      URL. The EHR provides the app two parameters:

      * `iss` - Which contains the FHIR server url
      * `launch` - An identifier needed for authorization

      # Test Methodology

      Inferno will wait for the EHR server redirect upon execution. When the
      redirect is received Inferno will check for the presence of the `iss`
      and `launch` parameters. The security of the authorization endpoint is
      then checked and authorization is attempted using the provided `launch`
      identifier.

      For more information on the #{title} see:

      * [SMART EHR Launch Sequence](https://www.hl7.org/fhir/smart-app-launch/1.0.0/index.html#ehr-launch-sequence)
    )

    config(
      inputs: {
        smart_auth_info: {
          name: :ehr_smart_auth_info,
          title: 'EHR Launch Credentials',
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
                default: 'launch openid fhirUser offline_access user/*.read'
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
          title: 'EHR Launch FHIR Endpoint',
          description: 'URL of the FHIR endpoint used by EHR launched applications'
        },
        code: {
          name: :ehr_code
        },
        state: {
          name: :ehr_state
        },
        launch: {
          name: :ehr_launch
        },
        smart_credentials: {
          name: :ehr_smart_credentials
        }
      },
      outputs: {
        launch: { name: :ehr_launch },
        code: { name: :ehr_code },
        token_retrieval_time: { name: :ehr_token_retrieval_time },
        state: { name: :ehr_state },
        id_token: { name: :ehr_id_token },
        refresh_token: { name: :ehr_refresh_token },
        access_token: { name: :ehr_access_token },
        expires_in: { name: :ehr_expires_in },
        patient_id: { name: :ehr_patient_id },
        encounter_id: { name: :ehr_encounter_id },
        received_scopes: { name: :ehr_received_scopes },
        intent: { name: :ehr_intent },
        smart_credentials: { name: :ehr_smart_credentials },
        smart_auth_info: { name: :ehr_smart_auth_info }
      },
      requests: {
        launch: { name: :ehr_launch },
        redirect: { name: :ehr_redirect },
        token: { name: :ehr_token }
      }
    )

    test from: :smart_app_launch
    test from: :smart_launch_received
    test from: :smart_tls,
         id: :ehr_auth_tls,
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
    test from: :smart_app_redirect do
      input :launch
    end
    test from: :smart_code_received
    test from: :smart_tls,
         id: :ehr_token_tls,
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
