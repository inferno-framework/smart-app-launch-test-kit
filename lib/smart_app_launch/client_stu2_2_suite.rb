require_relative 'endpoints/mock_smart_server/token_endpoint'
require_relative 'endpoints/mock_smart_server/authorization_endpoint'
require_relative 'endpoints/mock_smart_server/introspection_endpoint'
require_relative 'endpoints/echoing_fhir_responder_endpoint'
require_relative 'tags'
require_relative 'urls'
require_relative 'client_suite/registration_group'
require_relative 'client_suite/access_group'
require_relative 'client_suite/oidc_jwks'
require_relative 'client_suite/client_options'

module SMARTAppLaunch
  class SMARTClientSTU22Suite < Inferno::TestSuite
    id :smart_client_stu2_2 # rubocop:disable Naming/VariableNumber
    title 'SMART App Launch STU2.2 Client'
    description File.read(File.join(__dir__, 'docs', 'smart_stu2_2_client_suite_description.md'))

    links [
      {
        type: 'source_code',
        label: 'Open Source',
        url: 'https://github.com/inferno-framework/smart-app-launch-test-kit/'
      },
      {
        type: 'report_issue',
        label: 'Report Issue',
        url: 'https://github.com/inferno-framework/smart-app-launch-test-kit/issues/'
      },
      {
        type: 'download',
        label: 'Download',
        url: 'https://github.com/inferno-framework/smart-app-launch-test-kit/releases/'
      },
      {
        type: 'ig',
        label: 'Implementation Guide',
        url: 'https://hl7.org/fhir/smart-app-launch/STU2.2/'
      }
    ]

    suite_option :client_type,
                 title: 'SMART Client Type',
                 list_options: [
                   {
                     label: 'SMART App Launch Public Client',
                     value: SMARTClientOptions::SMART_APP_LAUNCH_PUBLIC
                   },
                   {
                     label: 'SMART App Launch Confidential Symmetric Client',
                     value: SMARTClientOptions::SMART_APP_LAUNCH_CONFIDENTIAL_SYMMETRIC
                   },
                   {
                     label: 'SMART App Launch Confidential Asymmetric Client',
                     value: SMARTClientOptions::SMART_APP_LAUNCH_CONFIDENTIAL_ASYMMETRIC
                   },
                   {
                     label: 'SMART Backend Services Confidential Asymmetric Client',
                     value: SMARTClientOptions::SMART_BACKEND_SERVICES_CONFIDENTIAL_ASYMMETRIC
                   }
                 ]

    route(:get, SMART_DISCOVERY_PATH, ->(_env) {MockSMARTServer.smart_server_metadata(id) }) 
    route(:get, OIDC_DISCOVERY_PATH, ->(_env) {MockSMARTServer.openid_connect_metadata(id) }) 
    route(
      :get,
      OIDC_JWKS_PATH,
      ->(_env) { [200, { 'Content-Type' => 'application/json' }, [OIDCJWKS.jwks_json]] }
    )

    suite_endpoint :get, AUTHORIZATION_PATH, MockSMARTServer::AuthorizationEndpoint
    suite_endpoint :post, AUTHORIZATION_PATH, MockSMARTServer::AuthorizationEndpoint
    suite_endpoint :post, INTROSPECTION_PATH, MockSMARTServer::IntrospectionEndpoint
    suite_endpoint :post, TOKEN_PATH, MockSMARTServer::TokenEndpoint
    suite_endpoint :get, FHIR_PATH, EchoingFHIRResponderEndpoint
    suite_endpoint :post, FHIR_PATH, EchoingFHIRResponderEndpoint
    suite_endpoint :put, FHIR_PATH, EchoingFHIRResponderEndpoint
    suite_endpoint :delete, FHIR_PATH, EchoingFHIRResponderEndpoint
    suite_endpoint :get, "#{FHIR_PATH}/:one", EchoingFHIRResponderEndpoint
    suite_endpoint :post, "#{FHIR_PATH}/:one", EchoingFHIRResponderEndpoint
    suite_endpoint :put, "#{FHIR_PATH}/:one", EchoingFHIRResponderEndpoint
    suite_endpoint :delete, "#{FHIR_PATH}/:one", EchoingFHIRResponderEndpoint
    suite_endpoint :get, "#{FHIR_PATH}/:one/:two", EchoingFHIRResponderEndpoint
    suite_endpoint :post, "#{FHIR_PATH}/:one/:two", EchoingFHIRResponderEndpoint
    suite_endpoint :put, "#{FHIR_PATH}/:one/:two", EchoingFHIRResponderEndpoint
    suite_endpoint :delete, "#{FHIR_PATH}/:one/:two", EchoingFHIRResponderEndpoint
    suite_endpoint :get, "#{FHIR_PATH}/:one/:two/:three", EchoingFHIRResponderEndpoint
    suite_endpoint :post, "#{FHIR_PATH}/:one/:two/:three", EchoingFHIRResponderEndpoint
    suite_endpoint :put, "#{FHIR_PATH}/:one/:two/:three", EchoingFHIRResponderEndpoint
    suite_endpoint :delete, "#{FHIR_PATH}/:one/:two/:three", EchoingFHIRResponderEndpoint

    resume_test_route :get, RESUME_PASS_PATH do |request|
      request.query_parameters['token']
    end

    resume_test_route :get, RESUME_FAIL_PATH, result: 'fail' do |request|
      request.query_parameters['token']
    end

    group from: :smart_client_registration
    group from: :smart_client_access
  end
end
