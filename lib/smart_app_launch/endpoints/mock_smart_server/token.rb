# frozen_string_literal: true

require_relative '../../urls'
require_relative '../../tags'
require_relative '../mock_smart_server'

module SMARTAppLaunch
  module MockSMARTServer
    class TokenEndpoint < Inferno::DSL::SuiteEndpoint
      def test_run_identifier
        MockSMARTServer.client_id_from_client_assertion(request.params[:client_assertion])
      end

      def make_response
        MockSMARTServer.make_smart_token_response(request, response, result)
      end

      def update_result
        nil # never update for now
      end

      def tags
        [TOKEN_TAG, SMART_TAG]
      end
    end
  end
end
