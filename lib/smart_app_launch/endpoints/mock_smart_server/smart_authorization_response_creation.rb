require_relative '../../tags'
require_relative '../mock_smart_server'
require_relative '../../client_suite/oidc_jwks'

module SMARTAppLaunch
  module MockSMARTServer
    module SMARTAuthorizationResponseCreation
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
        response.headers['Location'] =  "#{redirect_uri}#{redirect_uri.include?('?') ? '&' : '?'}#{query_string}"
        response.status = 302
      end
    end 
  end
end