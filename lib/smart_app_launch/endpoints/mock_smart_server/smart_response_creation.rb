require_relative '../../tags'
require_relative '../mock_smart_server'
require_relative '../../client_suite/oidc_jwks'

module SMARTAppLaunch
  module MockSMARTServer
    module SMARTResponseCreation
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
      
      def make_smart_authorization_code_token_response
        authorization_code = request.params[:code]
        client_id = MockSMARTServer.issued_token_to_client_id(authorization_code)
        return unless MockSMARTServer.authenticated?(request, response, result, client_id)

        if MockSMARTServer.token_expired?(authorization_code)
          MockSMARTServer.update_response_for_expired_token(response, 'Authorization code')
          return
        end

        authorization_request = MockSMARTServer.authorization_request_for_code(authorization_code,
                                                                               test_run.test_session_id)
        if authorization_request.blank?
          MockSMARTServer.update_response_for_invalid_assertion(
            response,
            "no authorization request found for code #{authorization_code}"
          )
          return
        end
        auth_code_request_inputs = MockSMARTServer.authorization_code_request_details(authorization_request)
        if auth_code_request_inputs.blank?
          MockSMARTServer.update_response_for_invalid_assertion(
            response,
            'invalid authorization request details'
          )
          return
        end
 
        return if request.params[:code_verifier].present? && !smart_pkce_valid?(auth_code_request_inputs)

        exp_min = 60
        response_body = {
          access_token: MockSMARTServer.client_id_to_token(client_id, exp_min),
          token_type: 'Bearer',
          expires_in: 60 * exp_min,
          scope: auth_code_request_inputs['scope']
        }

        launch_context =
          begin
            input_string = JSON.parse(result.input_json)&.find do |input|
              input['name'] == 'launch_context'
            end&.dig('value')
            JSON.parse(input_string) if input_string.present?
          rescue JSON::ParserError
            nil
          end
        additional_context = smart_requested_scope_context(auth_code_request_inputs['scope'], authorization_code, 
                                                           launch_context)

        response.body = additional_context.merge(response_body).to_json # response body values take priority
        response.headers['Cache-Control'] = 'no-store'
        response.headers['Pragma'] = 'no-cache'
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.content_type = 'application/json'
        response.status = 200
      end

      def make_smart_refresh_token_response
        refresh_token = request.params[:refresh_token]
        authorization_code = MockSMARTServer.refresh_token_to_authorization_code(refresh_token)
        client_id = MockSMARTServer.issued_token_to_client_id(authorization_code)
        return unless MockSMARTServer.authenticated?(request, response, result, client_id)

        # no expiration checks for refresh tokens

        authorization_request = MockSMARTServer.authorization_request_for_code(authorization_code,
                                                                               test_run.test_session_id)
        if authorization_request.blank?
          MockSMARTServer.update_response_for_invalid_assertion(
            response,
            "no authorization request found for refresh token #{refresh_token}"
          )
          return
        end
        auth_code_request_inputs = MockSMARTServer.authorization_code_request_details(authorization_request)
        if auth_code_request_inputs.blank?
          MockSMARTServer.update_response_for_invalid_assertion(
            response,
            'invalid authorization request details'
          )
          return
        end

        exp_min = 60
        response_body = {
          access_token: MockSMARTServer.client_id_to_token(client_id, exp_min),
          token_type: 'Bearer',
          expires_in: 60 * exp_min,
          scope: request.params[:scope].present? ? request.params[:scope] : auth_code_request_inputs['scope']
        }

        launch_context =
          begin
            input_string = JSON.parse(result.input_json)&.find do |input|
              input['name'] == 'launch_context'
            end&.dig('value')
            JSON.parse(input_string) if input_string.present?
          rescue JSON::ParserError
            nil
          end
        additional_context = smart_requested_scope_context(auth_code_request_inputs['scope'], authorization_code,
                                                           launch_context)

        response.body = additional_context.merge(response_body).to_json # response body values take priority
        response.headers['Cache-Control'] = 'no-store'
        response.headers['Pragma'] = 'no-cache'
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.content_type = 'application/json'
        response.status = 200
      end

      def make_smart_client_credential_token_response
        assertion = request.params[:client_assertion]
        client_id = MockSMARTServer.client_id_from_client_assertion(assertion)

        # by loading from DB rather than result inputs don't have to be associated with specific tests
        # e.g., key set input present on registration and auth checks, not during wait tests
        key_set_input = Inferno::Repositories::SessionData.new.load( 
          test_session_id: result.test_session_id, name: 'smart_jwk_set'
        )
        signature_error = MockSMARTServer.smart_assertion_signature_verification(assertion, key_set_input)

        if signature_error.present?
          MockSMARTServer.update_response_for_invalid_assertion(response, signature_error)
          return
        end

        exp_min = 60
        response_body = {
          access_token: MockSMARTServer.client_id_to_token(client_id, exp_min),
          token_type: 'Bearer',
          expires_in: 60 * exp_min,
          scope: request.params[:scope]
        }

        response.body = response_body.to_json
        response.headers['Cache-Control'] = 'no-store'
        response.headers['Pragma'] = 'no-cache'
        response.headers['Access-Control-Allow-Origin'] = '*'
        response.content_type = 'application/json'
        response.status = 200
      end

      def smart_requested_scope_context(requested_scopes, authorization_code, launch_context)
        context = launch_context.present? ? launch_context : {}
        scopes_list = requested_scopes.split

        if scopes_list.include?('offline_access') || scopes_list.include?('online_access')
          context[:refresh_token] = MockSMARTServer.authorization_code_to_refresh_token(authorization_code)
        end

        context[:id_token] = smart_construct_id_token(scopes_list.include?('fhirUser')) if scopes_list.include?('openid')

        context
      end

      def smart_construct_id_token(include_fhir_user)
        client_id = JSON.parse(result.input_json)&.find do |input|
          input['name'] == 'client_id'
        end&.dig('value')
        fhir_user_relative_reference = JSON.parse(result.input_json)&.find do |input|
          input['name'] == 'fhir_user_relative_reference'
        end&.dig('value')
        # TODO: how to generate the id - is this ok?
        subject_id = if fhir_user_relative_reference.present?
                      fhir_user_relative_reference.downcase.gsub('/', '-')
                    else
                      SecureRandom.uuid
                    end

        claims = {
          iss: client_fhir_base_url,
          sub: subject_id,
          aud: client_id,
          exp: 1.year.from_now.to_i,
          iat: Time.now.to_i
        }
        if include_fhir_user && fhir_user_relative_reference.present?
          claims[:fhirUser] = "#{fhir_user_relative_reference}/#{fhir_user_relative_reference}"
        end

        algorithm = 'RS256'
        private_key = OIDCJWKS.jwks
          .select { |key| key[:key_ops]&.include?('sign') }
          .select { |key| key[:alg] == algorithm }
          .first

        JWT.encode claims, private_key.signing_key, algorithm, { alg: algorithm, kid: private_key.kid, typ: 'JWT' }
      end

      def smart_pkce_valid?(auth_code_request_inputs)
        verifier = request.params[:code_verifier]
        challenge = auth_code_request_inputs&.dig('code_challenge')
        method = auth_code_request_inputs&.dig('code_challenge_method')
        MockSMARTServer.pkce_valid?(verifier, challenge, method, response)
      end

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