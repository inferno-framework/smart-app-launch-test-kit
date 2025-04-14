# frozen_string_literal: true

require_relative '../../urls'
require_relative '../../tags'
require_relative '../mock_smart_server'
require_relative '../../client_suite/oidc_jwks'

module SMARTAppLaunch
  module MockSMARTServer
    class TokenEndpoint < Inferno::DSL::SuiteEndpoint
      include URLs

      def test_run_identifier
        case request.params[:grant_type]
        when 'client_credentials'
          MockSMARTServer.client_id_from_client_assertion(request.params[:client_assertion])
        when 'authorization_code'
          MockSMARTServer.issued_token_to_client_id(request.params[:code])
        when 'refresh_token'
          MockSMARTServer.issued_token_to_client_id(
            MockSMARTServer.refresh_token_to_authorization_code(request.params[:refresh_token])
          )
        end
      end

      def make_response
        case request.params[:grant_type]
        when 'client_credentials'
          make_smart_client_credential_token_response
        when 'authorization_code'
          make_smart_authorization_code_token_response
        when 'refresh_token'
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
        workflow_tag = 
          case request.params[:grant_type]
          when 'client_credentials'
            CLIENT_CREDENTIALS_TAG
          when 'authorization_code'
            AUTHORIZATION_CODE_TAG
          when 'refresh_token'
            REFRESH_TOKEN_TAG
          end  
       tags << workflow_tag unless workflow_tag.blank?

       tags
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

        return if request.params[:code_verifier].present? && !pkce_valid?(auth_code_request_inputs)

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
        additional_context = requested_scope_context(auth_code_request_inputs['scope'], authorization_code, launch_context)

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
            JSON.parse(input_string)
          rescue JSON::ParserError
            nil
          end
        additional_context = requested_scope_context(auth_code_request_inputs['scope'], authorization_code,
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
  
        key_set_input = JSON.parse(result.input_json)&.find do |input|
          input['name'] == 'smart_jwk_set'
        end&.dig('value')
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

      def requested_scope_context(requested_scopes, authorization_code, launch_context)
        context = launch_context.present? ? launch_context : {}
        scopes_list = requested_scopes.split
  
        if scopes_list.include?('offline_access') || scopes_list.include?('online_access')
          context[:refresh_token] = MockSMARTServer.authorization_code_to_refresh_token(authorization_code)
        end
  
        context[:id_token] = construct_id_token(scopes_list.include?('fhirUser')) if scopes_list.include?('openid')
  
        context
      end
  
      def construct_id_token(include_fhir_user)
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

      def pkce_valid?(auth_code_request_inputs)
        verifier = request.params[:code_verifier]
        challenge = auth_code_request_inputs&.dig('code_challenge')
        method = auth_code_request_inputs&.dig('code_challenge_method')
        MockSMARTServer.pkce_valid?(verifier, challenge, method, response)
      end
    end
  end
end
