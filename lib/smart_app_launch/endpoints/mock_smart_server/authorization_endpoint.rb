# frozen_string_literal: true
require_relative '../../tags'
require_relative 'smart_response_creation'

module SMARTAppLaunch
  module MockSMARTServer
    class AuthorizationEndpoint < Inferno::DSL::SuiteEndpoint
      include SMARTResponseCreation

      def test_run_identifier  
        request.params[:client_id]
      end

      def make_response
        make_smart_authorization_response
      end

      def update_result
        nil # never update for now
      end

      def tags
        [AUTHORIZATION_TAG, SMART_TAG]
      end
    end
  end
end
