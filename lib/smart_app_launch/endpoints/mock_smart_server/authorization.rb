# frozen_string_literal: true

require_relative '../../urls'
require_relative '../../tags'
require_relative '../mock_smart_server'

module SMARTAppLaunch
  module MockSMARTServer
    class AuthorizationEndpoint < Inferno::DSL::SuiteEndpoint
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

      def make_smart_authorization_response
        redirect_uri = request.params[:redirect_uri]
        if redirect_uri.blank?
          response.status = 400
          response.body = { 
            error: 'Bad request',
            message: 'Missing required redirect_uri parameter.'}.to_json
          response.content_type = 'application/json'
          return
        end
  
        client_id = request.params[:client_id]
        state = request.params[:state]
  
        exp_min = 10
        token = MockSMARTServer.client_id_to_token(client_id, exp_min)
        query_string = "code=#{ERB::Util.url_encode(token)}&state=#{ERB::Util.url_encode(state)}"
        response.headers['Location'] = "#{redirect_uri}?#{query_string}"
        response.status = 302
      end
    end
  end
end
