require 'jwt'
require 'faraday'
require 'time'
require 'base64'
require_relative '../urls'
require_relative '../tags'
require_relative '../client_suite/client_options'

module SMARTAppLaunch
  module MockSMARTServer
    SUPPORTED_SCOPES = ['system/*.read', 'user/*.read', 'patient/*.read'].freeze

    module_function

    def smart_server_metadata(suite_id)
      base_url = "#{Inferno::Application['base_url']}/custom/#{suite_id}"
      response_body = {
        token_endpoint_auth_signing_alg_values_supported: ['RS384', 'ES384'],
        capabilities: ['client-confidential-asymmetric', 'launch-ehr' ,'launch-standalone', 'authorize-post',
                       'client-public', 'client-confidential-symmetric', 'permission-offline', 'permission-online',
                       'permission-patient', 'permission-user', 'permission-v1', 'permission-v2',
                       'context-ehr-patient', 'context-ehr-encounter', 
                       'context-standalone-patient', 'context-standalone-encounter',
                       'context-banner', 'context-style'],
        code_challenge_methods_supported: ['S256'],
        token_endpoint_auth_methods_supported: ['private_key_jwt', 'client_secret_basic'],
        issuer: base_url + FHIR_PATH,
        grant_types_supported: ['client_credentials', 'authorization_code'],
        scopes_supported: SUPPORTED_SCOPES,
        authorization_endpoint: base_url + AUTHORIZATION_PATH,
        token_endpoint: base_url + TOKEN_PATH,
        introspection_endpoint: base_url + INTROSPECTION_PATH
      }.to_json

      [200, { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*' }, [response_body]]
    end

    def openid_connect_metadata(suite_id)
      base_url = "#{Inferno::Application['base_url']}/custom/#{suite_id}"
      response_body = {
        issuer: base_url + FHIR_PATH,
        authorization_endpoint: base_url + AUTHORIZATION_PATH,
        token_endpoint: base_url + TOKEN_PATH,
        jwks_uri: base_url + OIDC_JWKS_PATH,
        response_types_supported: ['code', 'id_token', 'token id_token'],
        subject_types_supported: ['pairwise', 'public'],
        id_token_signing_alg_values_supported: ['RS256']
      }.to_json

      [200, { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*' }, [response_body]]
    end

    def client_id_from_client_assertion(client_assertion_jwt)
      return unless client_assertion_jwt.present?

      jwt_claims(client_assertion_jwt)&.dig('iss')
    end

    def parsed_request_body(request)
      JSON.parse(request.request_body)
    rescue JSON::ParserError
      nil
    end

    def parsed_io_body(request)
      parsed_body = begin
        JSON.parse(request.body.read)
      rescue JSON::ParserError
        nil
      end
      request.body.rewind

      parsed_body
    end

    def jwt_claims(encoded_jwt)
      JWT.decode(encoded_jwt, nil, false)[0]
    end

    def client_id_to_token(client_id, exp_min)
      token_structure = {
        client_id:,
        expiration: exp_min.minutes.from_now.to_i,
        nonce: SecureRandom.hex(8)
      }.to_json

      Base64.urlsafe_encode64(token_structure, padding: false)
    end

    def decode_token(token)
      token_to_decode = 
        if issued_token_is_refresh_token(token)
          refresh_token_to_authorization_code(token)
        else
          token
        end
      JSON.parse(Base64.urlsafe_decode64(token_to_decode))
    rescue JSON::ParserError
      nil
    end

    def issued_token_to_client_id(token)
      decode_token(token)&.dig('client_id')
    end

    def issued_token_is_refresh_token(token)
      token.end_with?('_rt')
    end

    def authorization_code_to_refresh_token(code)
      "#{code}_rt"
    end

    def refresh_token_to_authorization_code(refresh_token)
      refresh_token[..-4]
    end

    def jwk_set(jku, warning_messages = []) # rubocop:disable Metrics/CyclomaticComplexity
      jwk_set = JWT::JWK::Set.new

      if jku.blank?
        warning_messages << 'No key set input.'
        return jwk_set
      end

      jwk_body = # try as raw jwk set
        begin
          JSON.parse(jku)
        rescue JSON::ParserError
          nil
        end

      if jwk_body.blank?
        retrieved = Faraday.get(jku) # try as url pointing to a jwk set
        jwk_body =
          begin
            JSON.parse(retrieved.body)
          rescue JSON::ParserError
            warning_messages << "Failed to fetch valid json from jwks uri #{jwk_set}."
            nil
          end
      else
        warning_messages << 'Providing the JWK Set directly is strongly discouraged.'
      end

      return jwk_set if jwk_body.blank?

      jwk_body['keys']&.each_with_index do |key_hash, index|
        parsed_key =
          begin
            JWT::JWK.new(key_hash)
          rescue JWT::JWKError => e
            id = key_hash['kid'] | index
            warning_messages << "Key #{id} invalid: #{e}"
            nil
          end
        jwk_set << parsed_key unless parsed_key.blank?
      end

      jwk_set
    end

    def request_has_expired_token?(request)
      return false if request.params[:session_path].present?

      token = request.headers['authorization']&.delete_prefix('Bearer ')
      token_expired?(token)
    end

    def token_expired?(token, check_time = nil)
      decoded_token = decode_token(token)
      return false unless decoded_token&.dig('expiration').present?

      check_time = Time.now.to_i unless check_time.present?
      decoded_token['expiration'] < check_time
    end

    def update_response_for_expired_token(response, type)
      response.status = 401
      response.format = :json
      response.body = FHIR::OperationOutcome.new(
        issue: FHIR::OperationOutcome::Issue.new(severity: 'fatal', code: 'expired',
                                                 details: FHIR::CodeableConcept.new(text: "#{type}has expired"))
      ).to_json
    end

    def smart_assertion_signature_verification(token, key_set_input) # rubocop:disable Metrics/CyclomaticComplexity
      encoded_token = nil
      if token.is_a?(JWT::EncodedToken)
        encoded_token = token
      else
        begin
          encoded_token = JWT::EncodedToken.new(token)
        rescue StandardError => e
          return "invalid token structure: #{e}"
        end
      end
      return 'invalid token' unless encoded_token.present?
      return 'missing `alg` header' if encoded_token.header['alg'].blank?
      return 'missing `kid` header' if encoded_token.header['kid'].blank?

      jwk = identify_smart_signing_key(encoded_token.header['kid'], encoded_token.header['jku'], key_set_input)
      return "no key found with `kid` '#{encoded_token.header['kid']}'" if jwk.blank?

      begin
        encoded_token.verify_signature!(algorithm: encoded_token.header['alg'], key: jwk.verify_key)
      rescue StandardError => e
        return e
      end

      nil
    end

    def identify_smart_signing_key(kid, jku, key_set_input)
      key_set = jku.present? ? jku : key_set_input
      parsed_key_set = jwk_set(key_set)
      parsed_key_set&.find { |key| key.kid == kid }
    end

    def update_response_for_invalid_assertion(response, error_message)
      response.status = 401
      response.format = :json
      response.body = { error: 'invalid_client', error_description: error_message }.to_json
    end

    def authenticated?(request, response, result, client_id)
      suite_options_list = Inferno::Repositories::TestSessions.new.find(result.test_session_id)&.suite_options
      suite_options_hash = suite_options_list&.map { |so| [so.id, so.value] }&.to_h

      case SMARTClientOptions.smart_authentication_approach(suite_options_hash)
      when CONFIDENTIAL_ASYMMETRIC_TAG
        key_set_input = Inferno::Repositories::SessionData.new.load( 
          test_session_id: result.test_session_id, name: 'smart_jwk_set'
        )
        return confidential_asymmetric_authenticated?(request, response, key_set_input)
      when CONFIDENTIAL_SYMMETRIC_TAG
        client_secret_input = Inferno::Repositories::SessionData.new.load( 
          test_session_id: result.test_session_id, name: 'smart_client_secret'
        )
        return confidential_symmetric_authenticated?(request, response, client_id, client_secret_input)
      when PUBLIC_TAG
        return true
      end
    end

    def confidential_asymmetric_authenticated?(request, response, jwks)
      assertion = request.params[:client_assertion]
      if assertion.blank?
        update_response_for_invalid_assertion(
          response, 
          'client_assertion missing from confidential asymmetric client request'
        )
        return false
      end

      signature_error = smart_assertion_signature_verification(assertion, jwks)

      if signature_error.present?
        update_response_for_invalid_assertion(response, signature_error)
        return  false
      end
      
      true
    end

    def confidential_symmetric_authenticated?(request, response, client_id, client_secret)
      auth_header_value = request.headers['authorization']
      error = confidential_symmetric_header_value_error(auth_header_value, client_id, client_secret)
      if error.present?
        update_response_for_invalid_assertion(response, error)
        return false
      end
      
      true
    end

    def confidential_symmetric_header_value_error(authorization_header_value, client_id, client_secret)
      unless authorization_header_value.present?
        return 'authorization header missing from confidential symmetric client request'
      end
      unless authorization_header_value.start_with?('Basic ')
        return 'authorization header for confidential symmetric client request does not use Basic auth'
      end
      
      client_and_secret = Base64.decode64(authorization_header_value.delete_prefix('Basic '))
      expected_client_and_secret = "#{client_id}:#{client_secret}"
      unless client_and_secret == expected_client_and_secret
        return 'basic authorization header has the wrong decoded value - ' \
               "expected '#{client_and_secret}', got '#{expected_client_and_secret}'"
      end

      nil
    end

    def pkce_error(verifier, challenge, method)
      if verifier.blank?
        'pkce check failed: no verifier provided'
      elsif challenge.blank?
        'pkce check failed: no challenge code provided'
      elsif method == 'plain'
        return nil unless challenge != verifier

        "invalid plain pkce verifier: got '#{verifier}' expected '#{challenge}'"
      elsif method == 'S256'
        return nil unless challenge != AppRedirectTest.calculate_s256_challenge(verifier)

        "invalid S256 pkce verifier: got '#{AppRedirectTest.calculate_s256_challenge(verifier)}' " \
          "expected '#{challenge}'"
      else
        "invalid pkce challenge method '#{method}'"
      end
    end

    def pkce_valid?(verifier, challenge, method, response)
      pkce_error = pkce_error(verifier, challenge, method)

      if pkce_error.present?
        update_response_for_invalid_assertion(response, pkce_error)
        false
      else
        true
      end
    end

    def authorization_request_for_code(code, test_session_id)
      authorization_requests = Inferno::Repositories::Requests.new.tagged_requests(test_session_id, [AUTHORIZATION_TAG])
      authorization_requests.find do |request|
        location_header = request.response_headers.find { |header| header.name.downcase == 'location' }
        if location_header.present? && location_header.value.present?
          CGI.parse(URI(location_header.value)&.query)&.dig('code')&.first == code
        else
          false
        end
      end
    end

    def authorization_code_request_details(inferno_request)
      details_hash =
        if inferno_request.verb.downcase == 'get'
          CGI.parse(inferno_request.url.split('?')[1])
        elsif inferno_request.verb.downcase == 'post'
          CGI.parse(inferno_request.request_body)
        end

      details_hash&.keys&.each { |key| details_hash[key] = details_hash[key].first }
      details_hash
    end

    def extract_token_from_response(request)
      return unless request.status == 200

      JSON.parse(request.response_body)&.dig('access_token')
    rescue
      nil
    end
  end
end
