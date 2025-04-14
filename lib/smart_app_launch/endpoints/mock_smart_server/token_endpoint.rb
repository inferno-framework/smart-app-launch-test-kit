# frozen_string_literal: true

require_relative '../../urls'
require_relative '../../tags'
require_relative '../mock_smart_server'
require_relative '../../client_suite/oidc_jwks'
require_relative 'smart_token_response_creation'

module SMARTAppLaunch
  module MockSMARTServer
    class TokenEndpoint < Inferno::DSL::SuiteEndpoint
      include URLs
      include SMARTTokenResponseCreation

      def test_run_identifier
        case request.params[:grant_type]
        when 'client_credentials'
          MockSMARTServer.client_id_from_client_assertion(request.params[:client_assertion])
        when 'authorization_code'
          MockSMARTServer.issued_token_to_client_id(request.params[:code])
        when 'refresh_token'
          MockSMARTServer.issued_token_to_client_id(
            MockSMARTServer.refresh_token_to_authorization_code(request.params[:refresh_token])
          )
        end
      end

      def make_response
        case request.params[:grant_type]
        when 'client_credentials'
          make_smart_client_credential_token_response
        when 'authorization_code'
          make_smart_authorization_code_token_response
        when 'refresh_token'
          make_smart_refresh_token_response
        else
          MockSMARTServer.update_response_for_invalid_assertion(
            response,
            "unsupported grant_type: #{request.params[:grant_type]}"
          )
        end
      end

      def update_result
        nil # never update for now
      end

      def tags
        tags = [TOKEN_TAG, SMART_TAG]
        workflow_tag = 
          case request.params[:grant_type]
          when 'client_credentials'
            CLIENT_CREDENTIALS_TAG
          when 'authorization_code'
            AUTHORIZATION_CODE_TAG
          when 'refresh_token'
            REFRESH_TOKEN_TAG
          end  
       tags << workflow_tag unless workflow_tag.blank?

       tags
      end
  
      
    end
  end
end
