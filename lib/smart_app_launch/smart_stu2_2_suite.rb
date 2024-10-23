require 'tls_test_kit'

require_relative 'jwks'
require_relative 'version'
require_relative 'discovery_stu2_2_group'
require_relative 'standalone_launch_group_stu2_2'
require_relative 'ehr_launch_group_stu2_2'
require_relative 'openid_connect_group_stu2_2'
require_relative 'token_introspection_group_stu2_2'
require_relative 'backend_services_authorization_group'

module SMARTAppLaunch
  class SMARTSTU22Suite < Inferno::TestSuite
    id 'smart_stu2_2'
    title 'SMART App Launch STU2.2'
    version VERSION

    resume_test_route :get, '/launch' do |request|
      request.query_parameters['iss']
    end

    resume_test_route :get, '/redirect' do |request|
      request.query_parameters['state']
    end

    route(
      :get,
      '/.well-known/jwks.json',
      ->(_env) { [200, { 'Content-Type' => 'application/json' }, [JWKS.jwks_json]] }
    )

    @post_auth_page = File.read(File.join(__dir__, 'post_auth.html'))
    post_auth_handler = proc { [200, {}, [@post_auth_page]] }

    route :get, '/post_auth', post_auth_handler

    config options: {
      redirect_uri: "#{Inferno::Application['base_url']}/custom/smart_stu2_2/redirect",
      launch_uri: "#{Inferno::Application['base_url']}/custom/smart_stu2_2/launch",
      post_authorization_uri: "#{Inferno::Application['base_url']}/custom/smart_stu2_2/post_auth"
    }

    description <<~DESCRIPTION
      The SMART App Launch Test Suite verifies that systems correctly implement
      the [SMART App Launch IG](http://hl7.org/fhir/smart-app-launch/STU2.2/)
      for providing authorization and/or authentication services to client
      applications accessing HL7® FHIR® APIs. To get started, please first register
      the Inferno client as a SMART App with the following information:

      * SMART Launch URI: `#{config.options[:launch_uri]}`
      * OAuth Redirect URI: `#{config.options[:redirect_uri]}`

      If using asymmetric client authentication, register Inferno with the
      following JWK Set URL:

      * `#{Inferno::Application[:base_url]}/custom/smart_stu2_2/.well-known/jwks.json`

      **NOTE:** This suite does not currently test [CORS
        support](http://hl7.org/fhir/smart-app-launch/app-launch.html#considerations-for-cross-origin-resource-sharing-cors-support).
    DESCRIPTION

    input_instructions %(
      When running tests at this level, the token introspection endpoint is not available as a manual input.
      Instead, group 3 Token Introspection will assume the token introspection endpoint
      will be output from group 1 Standalone Launch tests, specifically the SMART On FHIR Discovery tests that query
      the .well-known/smart-configuration endpoint. However, including the token introspection
      endpoint as part of the well-known ouput is NOT required and is not formally checked in the SMART On FHIR Discovery
      tests.  RFC-7662 on Token Introspection says that "The means by which the protected resource discovers the location of the introspection
      endpoint are outside the scope of this specification" and the Token Introspection IG does not add any further
      requirements to this.

      If the token introspection endpoint of the system under test is NOT available at .well-known/smart-configuration,
      please run the test groups individually and group 3 Token Introspection will include the introspection endpoint as a manual input.
    )

    group do
      title 'Standalone Launch'
      id :smart_full_standalone_launch

      input_instructions <<~INSTRUCTIONS
        Please register the Inferno client as a SMART App with the following
        information:

        * OAuth Redirect URI: `#{config.options[:redirect_uri]}`

        If using asymmetric client authentication, register Inferno with the
        following JWK Set URL:

        * `#{Inferno::Application[:base_url]}/custom/smart_stu2_2/.well-known/jwks.json`
      INSTRUCTIONS

      run_as_group

      group from: :smart_discovery_stu2_2
      group from: :smart_standalone_launch_stu2_2

      group from: :smart_openid_connect_stu2_2,
            config: {
              inputs: {
                id_token: { name: :standalone_id_token },
                client_id: { name: :standalone_client_id },
                requested_scopes: { name: :standalone_requested_scopes },
                access_token: { name: :standalone_access_token },
                smart_credentials: { name: :standalone_smart_credentials }
              }
            }

      group from: :smart_token_refresh_stu2,
            id: :smart_standalone_refresh_without_scopes,
            title: 'SMART Token Refresh Without Scopes',
            config: {
              inputs: {
                refresh_token: { name: :standalone_refresh_token },
                client_id: { name: :standalone_client_id },
                client_secret: { name: :standalone_client_secret },
                received_scopes: { name: :standalone_received_scopes }
              },
              outputs: {
                refresh_token: { name: :standalone_refresh_token },
                received_scopes: { name: :standalone_received_scopes },
                access_token: { name: :standalone_access_token },
                token_retrieval_time: { name: :standalone_token_retrieval_time },
                expires_in: { name: :standalone_expires_in },
                smart_credentials: { name: :standalone_smart_credentials }
              }
            }

      group from: :smart_token_refresh_stu2,
            id: :smart_standalone_refresh_with_scopes,
            title: 'SMART Token Refresh With Scopes',
            config: {
              options: { include_scopes: true },
              inputs: {
                refresh_token: { name: :standalone_refresh_token },
                client_id: { name: :standalone_client_id },
                client_secret: { name: :standalone_client_secret },
                received_scopes: { name: :standalone_received_scopes }
              },
              outputs: {
                refresh_token: { name: :standalone_refresh_token },
                received_scopes: { name: :standalone_received_scopes },
                access_token: { name: :standalone_access_token },
                token_retrieval_time: { name: :standalone_token_retrieval_time },
                expires_in: { name: :standalone_expires_in },
                smart_credentials: { name: :standalone_smart_credentials }
              }
            }
    end

    group do
      title 'EHR Launch'
      id :smart_full_ehr_launch

      input_instructions <<~INSTRUCTIONS
        Please register the Inferno client as a SMART App with the following
        information:

        * SMART Launch URI: `#{config.options[:launch_uri]}`
        * OAuth Redirect URI: `#{config.options[:redirect_uri]}`

        If using asymmetric client authentication, register Inferno with the
        following JWK Set URL:

        * `#{Inferno::Application[:base_url]}/custom/smart_stu2_2/.well-known/jwks.json`
      INSTRUCTIONS

      run_as_group

      group from: :smart_discovery_stu2_2

      group from: :smart_ehr_launch_stu2_2

      group from: :smart_openid_connect_stu2_2,
            config: {
              inputs: {
                id_token: { name: :ehr_id_token },
                client_id: { name: :ehr_client_id },
                requested_scopes: { name: :ehr_requested_scopes },
                access_token: { name: :ehr_access_token },
                smart_credentials: { name: :ehr_smart_credentials }
              }
            }

      group from: :smart_token_refresh_stu2,
            id: :smart_ehr_refresh_without_scopes,
            title: 'SMART Token Refresh Without Scopes',
            config: {
              inputs: {
                refresh_token: { name: :ehr_refresh_token },
                client_id: { name: :ehr_client_id },
                client_secret: { name: :ehr_client_secret },
                received_scopes: { name: :ehr_received_scopes }
              },
              outputs: {
                refresh_token: { name: :ehr_refresh_token },
                received_scopes: { name: :ehr_received_scopes },
                access_token: { name: :ehr_access_token },
                token_retrieval_time: { name: :ehr_token_retrieval_time },
                expires_in: { name: :ehr_expires_in },
                smart_credentials: { name: :ehr_smart_credentials }
              }
            }

      group from: :smart_token_refresh_stu2,
            id: :smart_ehr_refresh_with_scopes,
            title: 'SMART Token Refresh With Scopes',
            config: {
              options: { include_scopes: true },
              inputs: {
                refresh_token: { name: :ehr_refresh_token },
                client_id: { name: :ehr_client_id },
                client_secret: { name: :ehr_client_secret },
                received_scopes: { name: :ehr_received_scopes }
              },
              outputs: {
                refresh_token: { name: :ehr_refresh_token },
                received_scopes: { name: :ehr_received_scopes },
                access_token: { name: :ehr_access_token },
                token_retrieval_time: { name: :ehr_token_retrieval_time },
                expires_in: { name: :ehr_expires_in },
                smart_credentials: { name: :ehr_smart_credentials }
              }
            }
    end

    group do
      title 'Backend Services'
      id :smart_backend_services

      input_instructions <<~INSTRUCTIONS
        Please register the Inferno client with the authorization services with the
        following JWK Set URL:

        * `#{Inferno::Application[:base_url]}/custom/smart_stu2_2/.well-known/jwks.json`
      INSTRUCTIONS

      run_as_group

      group from: :smart_discovery_stu2_2
      group from: :backend_services_authorization
    end

    group from: :smart_token_introspection_stu2_2
  end
end
