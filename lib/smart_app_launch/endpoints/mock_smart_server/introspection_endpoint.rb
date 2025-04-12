# frozen_string_literal: true

require_relative '../../urls'
require_relative '../../tags'
require_relative '../mock_smart_server'

module SMARTAppLaunch
  module MockSMARTServer
    class IntrospectionEndpoint < Inferno::DSL::SuiteEndpoint
      def test_run_identifier
        MockSMARTServer.issued_token_to_client_id(request.params[:token])
      end

      def make_response
        response.body = make_introspection_response.to_json
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

      def make_introspection_response
        target_token = request.params[:token]
        introspection_inactive_response_body = { active: false }

        return introspection_inactive_response_body if MockSMARTServer.token_expired?(target_token)
        
        token_requests = requests_repo.tagged_requests(test_run.test_session_id, [TOKEN_TAG])
        original_response_body = nil
        original_token_request = token_requests.find do |request|
          next unless request.status == 200

          original_response_body = JSON.parse(request.response_body)
          [original_response_body['access_token'], original_response_body['refresh_token']].include?(target_token)
        end
        return introspection_inactive_response_body unless original_token_request.present?

        decoded_token = MockSMARTServer.decode_token(target_token)
        introspection_active_response_body = {
          active: true,
          client_id: decoded_token['client_id'],
          exp: decoded_token['expiration']
        }
        original_response_body.each do |element, value|
          next if ['access_token', 'refresh_token', 'token_type', 'expires_in'].include?(element)
          next if introspection_active_response_body.key?(element)

          introspection_active_response_body[element] = value
        end
        if original_response_body.key?('id_token')
          user_claims, _header = JWT.decode(original_response_body['id_token'], nil, false)
          introspection_active_response_body['iss'] = user_claims['iss']
          introspection_active_response_body['sub'] = user_claims['sub']
          introspection_active_response_body['fhirUser'] = user_claims['fhirUser'] if user_claims['fhirUser'].present?
        end
        
        introspection_active_response_body
      end

      def requests_repo
        @requests_repo ||= Inferno::Repositories::Requests.new
      end
    end
  end
end
