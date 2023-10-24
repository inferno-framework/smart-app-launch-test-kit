require 'tls_test_kit'

require_relative 'jwks'
require_relative 'version'
require_relative 'discovery_stu2_group'
require_relative 'standalone_launch_group_stu2'
require_relative 'ehr_launch_group_stu2'
require_relative 'openid_connect_group'
require_relative 'token_refresh_group'
require_relative 'token_introspection_request_group'
require_relative 'token_introspection_response_group'

module SMARTAppLaunch
  class SMARTSTU2Suite < Inferno::TestSuite
    id 'smart_stu2'
    title 'SMART App Launch STU2'
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
      redirect_uri: "#{Inferno::Application['base_url']}/custom/smart_stu2/redirect",
      launch_uri: "#{Inferno::Application['base_url']}/custom/smart_stu2/launch",
      post_authorization_uri: "#{Inferno::Application['base_url']}/custom/smart_stu2/post_auth"
    }

    description <<~DESCRIPTION
      The SMART App Launch Test Suite verifies that systems correctly implement 
      the [SMART App Launch IG](http://hl7.org/fhir/smart-app-launch/STU2/) 
      for providing authorization and/or authentication services to client 
      applications accessing HL7® FHIR® APIs. To get started, please first register 
      the Inferno client as a SMART App with the following information:

      * SMART Launch URI: `#{config.options[:launch_uri]}`
      * OAuth Redirect URI: `#{config.options[:redirect_uri]}`

      If using asymmetric client authentication, register Inferno with the
      following JWK Set URL:

      * `#{Inferno::Application[:base_url]}/custom/smart_stu2/.well-known/jwks.json`
    DESCRIPTION

    group do
      title 'Standalone Launch'
      id :smart_full_standalone_launch

      input_instructions <<~INSTRUCTIONS
        Please register the Inferno client as a SMART App with the following
        information:

        * OAuth Redirect URI: `#{config.options[:redirect_uri]}`

        If using asymmetric client authentication, register Inferno with the
        following JWK Set URL:

        * `#{Inferno::Application[:base_url]}/custom/smart_stu2/.well-known/jwks.json`
      INSTRUCTIONS

      run_as_group

      group from: :smart_discovery_stu2
      group from: :smart_standalone_launch_stu2

      group from: :smart_openid_connect,
            config: {
              inputs: {
                id_token: { name: :standalone_id_token },
                client_id: { name: :standalone_client_id },
                requested_scopes: { name: :standalone_requested_scopes },
                access_token: { name: :standalone_access_token },
                smart_credentials: { name: :standalone_smart_credentials }
              }
            }

      group from: :smart_token_refresh,
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

      group from: :smart_token_refresh,
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

        * `#{Inferno::Application[:base_url]}/custom/smart_stu2/.well-known/jwks.json`
      INSTRUCTIONS

      run_as_group

      group from: :smart_discovery_stu2

      group from: :smart_ehr_launch_stu2

      group from: :smart_openid_connect,
            config: {
              inputs: {
                id_token: { name: :ehr_id_token },
                client_id: { name: :ehr_client_id },
                requested_scopes: { name: :ehr_requested_scopes },
                access_token: { name: :ehr_access_token },
                smart_credentials: { name: :ehr_smart_credentials }
              }
            }

      group from: :smart_token_refresh,
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

      group from: :smart_token_refresh,
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
  
    # TBD - group token introspection? 
    group do
      title 'Token Introspection'
      id :smart_token_introspection
      description %(
        # Background
        OAuth 2.0 Token introspection, as described in [RFC-7662](https://datatracker.ietf.org/doc/html/rfc7662), allows
        an authorized resource server to query an OAuth 2.0 authorization server for metadata on a token.  The
        [SMART App Launch STU 2.1 Implementation Guide Section on Token Introspection](https://hl7.org/fhir/smart-app-launch/token-introspection.html)
        states that "SMART on FHIR EHRs SHOULD support token introspection, which allows a broader ecosystem of resource servers
        to leverage authorization decisions managed by a single authorization server."
  
        # Test Methodology
        For these tests, Inferno acts as an authorized resource server that queries the authorization server about an access 
        token, rather than a client to a FHIR resource server as in the previous SMART App Launch tests.  By default, 
        Inferno will aim to introspect the access token from the Standalone Launch tests, but this can be changed with the test inputs. 
        
        Ideally, Inferno should be registered with the authorization server as an authorized resource server
        capable of accessing the token introspection endpoint through client credentials, per the SMART IG recommendations.  
        However, the SMART IG only formally REQUIRES "some form of authorization" to access
        the token endpoint and does specifiy any one specific approach.  As such, the token introspection tests are 
        broken up into two groups that can be run indepndently:

        1. Tests that complete the introspection request(s)
        2. Tests that validate the contents of the introspection response(s)

        If needed, the introspection request group can be run out of band from the introspection respone validation group
        to accommodate non-standard authorization approaches to secure the token endpoint.  
      )

      input_instructions <<~INSTRUCTIONS
        TODO: Instructions for token introspection go here!
      INSTRUCTIONS
      
      group from: :token_introspection_request_group
      group from: :token_introspection_response_group

    end
  end
end
