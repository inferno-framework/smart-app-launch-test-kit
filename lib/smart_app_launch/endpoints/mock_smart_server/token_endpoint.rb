# frozen_string_literal: true
require_relative '../../tags'
require_relative '../mock_smart_server'
require_relative 'smart_response_creation'

module SMARTAppLaunch
  module MockSMARTServer
    class TokenEndpoint < Inferno::DSL::SuiteEndpoint
      include URLs
      include SMARTResponseCreation

      def test_run_identifier
        case request.params[:grant_type]
        when CLIENT_CREDENTIALS_TAG
          MockSMARTServer.client_id_from_client_assertion(request.params[:client_assertion])
        when AUTHORIZATION_CODE_TAG
          MockSMARTServer.issued_token_to_client_id(request.params[:code])
        when REFRESH_TOKEN_TAG
          MockSMARTServer.issued_token_to_client_id(
            MockSMARTServer.refresh_token_to_authorization_code(request.params[:refresh_token])
          )
        end
      end

      def make_response
        case request.params[:grant_type]
        when CLIENT_CREDENTIALS_TAG
          make_smart_client_credential_token_response
        when AUTHORIZATION_CODE_TAG
          make_smart_authorization_code_token_response
        when REFRESH_TOKEN_TAG
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
        if [CLIENT_CREDENTIALS_TAG, AUTHORIZATION_CODE_TAG, REFRESH_TOKEN_TAG].include?(request.params[:grant_type])
          tags << request.params[:grant_type]
        end
        tags
      end    
    end
  end
end
