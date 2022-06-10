require 'tls_test_kit'

require_relative 'smart_app_launch/version'
require_relative 'smart_app_launch/discovery_group'
require_relative 'smart_app_launch/standalone_launch_group'
require_relative 'smart_app_launch/ehr_launch_group'
require_relative 'smart_app_launch/openid_connect_group'
require_relative 'smart_app_launch/token_refresh_group'

module SMARTAppLaunch
  class SMARTSuite < Inferno::TestSuite
    id 'smart'
    title 'SMART App Launch'
    version VERSION

    resume_test_route :get, '/launch' do
      request.query_parameters['iss']
    end

    resume_test_route :get, '/redirect' do
      request.query_parameters['state']
    end

    config options: {
      redirect_uri: "#{Inferno::Application['base_url']}/custom/smart/redirect",
      launch_uri: "#{Inferno::Application['base_url']}/custom/smart/launch"
    }

    group do
      title 'Standalone Launch'
      id :smart_full_standalone_launch

      run_as_group

      group from: :smart_discovery
      group from: :smart_standalone_launch

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

      run_as_group

      group from: :smart_discovery

      group from: :smart_ehr_launch

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
  end

  class SMARTV1Suite < SMARTSuite
    id 'smart_v1'
    title 'SMART App Launch STU1'
    suite_option :ig_version,
                 title: 'IG Version',
                 description: 'Which IG Version should be used',
                 list_options: [
                   {
                     label: 'v1',
                     value: '1'
                   }
                 ]
  end

  class SMARTV2Suite < SMARTSuite
    id 'smart_v2'
    title 'SMART App Launch STU2'
    suite_option :ig_version,
                 title: 'IG Version',
                 description: 'Which IG Version should be used',
                 list_options: [
                   {
                     label: 'v2',
                     value: '2'
                   }
                 ]
  end
end
