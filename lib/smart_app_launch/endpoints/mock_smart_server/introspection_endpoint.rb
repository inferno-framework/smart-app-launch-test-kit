# frozen_string_literal: true
require_relative '../../tags'
require_relative '../mock_smart_server'
require_relative 'smart_introspection_response_creation'

module SMARTAppLaunch
  module MockSMARTServer
    class IntrospectionEndpoint < Inferno::DSL::SuiteEndpoint
      include SMARTIntrospectionResponseCreation

      def test_run_identifier
        MockSMARTServer.issued_token_to_client_id(request.params[:token])
      end

      def make_response
        response.body = make_smart_introspection_response.to_json
        response.headers['Cache-Control'] = 'no-store'
        response.headers['Pragma'] = 'no-cache'
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.content_type = 'application/json'
        response.status = 200
      end

      def update_result
        nil # never update for now
      end

      def tags
        [INTROSPECTION_TAG, SMART_TAG]
      end
    end
  end
end
