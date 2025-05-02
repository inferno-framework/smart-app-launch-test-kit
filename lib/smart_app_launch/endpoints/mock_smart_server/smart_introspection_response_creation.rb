require_relative '../../tags'
require_relative '../mock_smart_server'

module SMARTAppLaunch
  module MockSMARTServer
    module SMARTIntrospectionResponseCreation 
      def make_smart_introspection_response
        target_token = request.params[:token]
        introspection_inactive_response_body = { active: false }

        return introspection_inactive_response_body if MockSMARTServer.token_expired?(target_token)
        
        token_requests = Inferno::Repositories::Requests.new.tagged_requests(test_run.test_session_id, [TOKEN_TAG])
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
    end 
  end
end