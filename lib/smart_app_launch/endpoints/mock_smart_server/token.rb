# frozen_string_literal: true

require_relative '../../urls'
require_relative '../../tags'
require_relative '../mock_smart_server'

module SMARTAppLaunch
  module MockSMARTServer
    class TokenEndpoint < Inferno::DSL::SuiteEndpoint
      def test_run_identifier
        if request.params[:grant_type] == 'client_credentials'
          MockSMARTServer.client_id_from_client_assertion(request.params[:client_assertion])
        elsif request.params[:grant_type] == 'authorization_code'
          MockSMARTServer.issued_token_to_client_id(request.params[:code])
        elsif request.params[:grant_type] == 'refresh_token'
          MockSMARTServer.issued_token_to_client_id(
            MockSMARTServer.refresh_token_to_authorization_code(request.params[:refresh_token])
          )
        end
      end

      def make_response
        if request.params[:grant_type] == 'client_credentials'
          make_smart_client_credential_token_response
        elsif request.params[:grant_type] == 'authorization_code'
          make_smart_authorization_code_token_response
        elsif request.params[:grant_type] == 'refresh_token'
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
            CLIENT_CREDENTIAL_TAG
          when 'authorization_code'
            AUTHORIZATION_CODE_TAG
          when 'refresh_token'
            REFRESH_TOKEN_TAG
          end  
       tags << workflow_tag unless workflow_tag.blank?

       tags
      end
  
      def make_smart_authorization_code_token_response
        code = request.params[:code]
        client_id = MockSMARTServer.issued_token_to_client_id(code)
        return unless MockSMARTServer.authenticated?(request, response, result, client_id)
        
        if MockSMARTServer.token_expired?(code)
          MockSMARTServer.update_response_for_expired_token(response, 'Authorization code')
          return
        end
  
        authorization_request = authorization_request_for_code(code)
        if authorization_request.blank?
          MockSMARTServer.update_response_for_invalid_assertion(
            response, 
            "no authorization request found that returned code #{code}"
          )
          return
        end
        auth_code_request_inputs = MockSMARTServer.authorization_code_request_details(authorization_request)
        if auth_code_request_inputs.blank?
          MockSMARTServer.update_response_for_invalid_assertion(
            response, 
            "invalid authorization request details"
          )
          return
        end

        verifier = request.params[:code_verifier]
        challenge = auth_code_request_inputs&.dig('code_challenge')
        method = auth_code_request_inputs&.dig('code_challenge_method')
        return unless MockSMARTServer.pkce_valid?(verifier, challenge, method, response)
  
        exp_min = 60
        response_body = {
          access_token: MockSMARTServer.client_id_to_token(client_id, exp_min),
          token_type: 'Bearer',
          expires_in: 60 * exp_min,
          scope: auth_code_request_inputs['scope']
        }

        additional_context = requested_scope_context(auth_code_request_inputs['scope'], code)
  
        response.body = response_body.merge(additional_context).to_json
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
  
        authorization_request = authorization_request_for_code(authorization_code)
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
            "invalid authorization request details"
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
        
        additional_context = requested_scope_context(auth_code_request_inputs['scope'], authorization_code)
  
        response.body = response_body.merge(additional_context).to_json
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

      def authorization_request_for_code(code)
        authorization_requests = requests_repo.tagged_requests(test_run.test_session_id, [SMART_TAG, AUTHORIZATION_TAG])
        authorization_requests.find do |request|
          location_header = request.response_headers.find { |header| header.name.downcase == 'location' }
          if location_header.present? && location_header.value.present?
            CGI.parse(URI(location_header.value)&.query)&.dig('code')&.first == code
          else
            false
          end
        end
      end

      def requests_repo
        @requests_repo ||= Inferno::Repositories::Requests.new
      end

      def requested_scope_context(requested_scopes, authorization_code)
        context = {}
        scopes_list = requested_scopes.split(' ')
        if scopes_list.include?('offline_access') || scopes_list.include?('online_access')
          context[:refresh_token] = MockSMARTServer.authorization_code_to_refresh_token(authorization_code)
        end

        context
      end
    end
  end
end
