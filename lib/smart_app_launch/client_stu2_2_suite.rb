require_relative 'endpoints/mock_smart_server/token'
require_relative 'endpoints/echoing_fhir_responder'
require_relative 'urls'
require_relative 'client_suite/client_registration_group'
require_relative 'client_suite/client_access_group'

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

    route(:get, SMART_DISCOVERY_PATH, ->(_env) {MockSMARTServer.smart_server_metadata(id) }) 
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

    group do
      title 'SMART Backend Services'
      description %(
        During these tests, the client will use SMART Backend Services
        to access a FHIR API. Clients will provide registeration details,
        obtain an access token, and use the access token when making a
        request to a FHIR API.
      )

      input :smart_jwk_set,
            optional: false

      group from: :smart_client_registration
      group from: :smart_client_access
    end
  end
end
