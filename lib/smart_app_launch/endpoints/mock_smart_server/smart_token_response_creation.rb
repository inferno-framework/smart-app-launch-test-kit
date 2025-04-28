require_relative '../../tags'
require_relative '../mock_smart_server'
require_relative '../../client_suite/oidc_jwks'

module SMARTAppLaunch
  module MockSMARTServer
    module SMARTTokenResponseCreation 
      def make_smart_authorization_code_token_response(smart_authentication_approach)
        authorization_code = request.params[:code]
        client_id = MockSMARTServer.issued_token_to_client_id(authorization_code)
        return unless authenticated?(client_id, smart_authentication_approach)

        if MockSMARTServer.token_expired?(authorization_code)
          MockSMARTServer.update_response_for_expired_token(response, 'Authorization code')
          return
        end

        authorization_request = MockSMARTServer.authorization_request_for_code(authorization_code,
                                                                               test_run.test_session_id)
        if authorization_request.blank?
          MockSMARTServer.update_response_for_error(
            response,
            "no authorization request found for code #{authorization_code}"
          )
          return
        end
        auth_code_request_inputs = MockSMARTServer.authorization_code_request_details(authorization_request)
        if auth_code_request_inputs.blank?
          MockSMARTServer.update_response_for_error(
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

      def make_smart_refresh_token_response(smart_authentication_approach)
        refresh_token = request.params[:refresh_token]
        authorization_code = MockSMARTServer.refresh_token_to_authorization_code(refresh_token)
        client_id = MockSMARTServer.issued_token_to_client_id(authorization_code)
        return unless authenticated?(client_id, smart_authentication_approach)

        # no expiration checks for refresh tokens

        authorization_request = MockSMARTServer.authorization_request_for_code(authorization_code,
                                                                               test_run.test_session_id)
        if authorization_request.blank?
          MockSMARTServer.update_response_for_error(
            response,
            "no authorization request found for refresh token #{refresh_token}"
          )
          return
        end
        auth_code_request_inputs = MockSMARTServer.authorization_code_request_details(authorization_request)
        if auth_code_request_inputs.blank?
          MockSMARTServer.update_response_for_error(
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
        return unless confidential_asymmetric_authenticated?(key_set_input)

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
        scopes_list = requested_scopes&.split || []

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
          claims[:fhirUser] = "#{client_fhir_base_url}/#{fhir_user_relative_reference}"
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

      def authenticated?(client_id, smart_authentication_approach)
        case smart_authentication_approach
        when CONFIDENTIAL_ASYMMETRIC_TAG
          key_set_input = Inferno::Repositories::SessionData.new.load( 
            test_session_id: result.test_session_id, name: 'smart_jwk_set'
          )
          return confidential_asymmetric_authenticated?(key_set_input)
        when CONFIDENTIAL_SYMMETRIC_TAG
          client_secret_input = Inferno::Repositories::SessionData.new.load( 
            test_session_id: result.test_session_id, name: 'smart_client_secret'
          )
          return confidential_symmetric_authenticated?(client_id, client_secret_input)
        when PUBLIC_TAG
          return true
        end
      end
  
      def confidential_asymmetric_authenticated?(jwks)
        assertion = request.params[:client_assertion]
        if assertion.blank?
          MockSMARTServer.update_response_for_error(
            response, 
            'client_assertion missing from confidential asymmetric client request'
          )
          return false
        end
  
        signature_error = MockSMARTServer.smart_assertion_signature_verification(assertion, jwks)
  
        if signature_error.present?
          MockSMARTServer.update_response_for_error(response, signature_error)
          return  false
        end
        
        true
      end
  
      def confidential_symmetric_authenticated?(client_id, client_secret)
        auth_header_value = request.headers['authorization']
        error = MockSMARTServer.confidential_symmetric_header_value_error(auth_header_value, client_id, client_secret)
        if error.present?
          MockSMARTServer.update_response_for_error(response, error)
          return false
        end
        
        true
      end  
    end 
  end
end