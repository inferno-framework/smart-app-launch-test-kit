require 'jwt'
require 'faraday'
require 'time'
require 'base64'
require_relative '../urls'
require_relative '../tags'

module SMARTAppLaunch
  module MockSMARTServer
    SUPPORTED_SCOPES = ['openid', 'system/*.read', 'user/*.read', 'patient/*.read'].freeze

    module_function

    def smart_server_metadata(suite_id)
      base_url = "#{Inferno::Application['base_url']}/custom/#{suite_id}"
      response_body = {
        token_endpoint_auth_signing_alg_values_supported: ['RS384', 'ES384'],
        capabilities: ['client-confidential-asymmetric'],
        code_challenge_methods_supported: ['S256'],
        token_endpoint_auth_methods_supported: ['private_key_jwt'],
        issuer: base_url + FHIR_PATH,
        grant_types_supported: ['client_credentials', 'authorization_code'],
        scopes_supported: SUPPORTED_SCOPES,
        authorization_endpoint: base_url + AUTHORIZATION_PATH,
        token_endpoint: base_url + TOKEN_PATH
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

    def client_uri_to_client_id(client_uri)
      Base64.urlsafe_encode64(client_uri, padding: false)
    end

    def client_id_to_client_uri(client_id)
      Base64.urlsafe_decode64(client_id)
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
      JSON.parse(Base64.urlsafe_decode64(token))
    rescue JSON::ParserError
      nil
    end

    def issued_token_to_client_id(token)
      decode_token(token)&.dig('client_id')
    end

    def authorization_code_to_refresh_token(code)
      "#{code}rt"
    end

    def refresh_token_to_authorization_code(refresh_token)
      refresh_token[..-3]
    end

    def registered_client_type(jwks, client_secret)
      if jwks.present?
        :confidential_asymmetric
      elsif client_secret.present?
        :confidential_symmetric
      else
        :public
      end
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
      
      # configuration inputs
      key_set_input = JSON.parse(result.input_json)&.find do |input|
        input['name'] == 'smart_jwk_set'
      end&.dig('value')
      client_secret_input = JSON.parse(result.input_json)&.find do |input|
        input['name'] == 'client_secret'
      end&.dig('value')

      case registered_client_type(key_set_input, client_secret_input)
      when :confidential_asymmetric
        return confidential_asymmetric_authenticated?(request, response, key_set_input)
      when :confidential_symmetric
        return confidential_symmetric_authenticated?(request, response, client_id, client_secret_input)
      when :public
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
      auth_header_value = request.request_headers.find { |header| header.name.downcase == 'authorization' }&.value
      if auth_header_value.blank?
        update_response_for_invalid_assertion(
          response, 
          'authorization header missing from confidential symmetric client request'
        )
        return false
      end
      unless auth_header_value.start_with?('Basic ')
        update_response_for_invalid_assertion(
          response, 
          'authorization header for confidential symmetric client request does not use Basic auth'
        )
        return false
      end
      auth_client, auth_secret = Base64.decode64(auth_header_value.delete_prefix('Basic ')).split(':')
      unless auth_client == client_id
        update_response_for_invalid_assertion(
          response, 
          "authorization header has the wrong client: expected '#{client_id}', got '#{auth_client}'"
        )
        return false
      end
      unless auth_secret == client_secret
        update_response_for_invalid_assertion(
          response, 
          "authorization header has the wrong secret: expected '#{client_secret}', got '#{auth_secret}'"
        )
        return false
      end
    
      true
    end

    def pkce_valid?(verifier, challenge, method, response)
      if verifier.blank?
        update_response_for_invalid_assertion(
          response, 
          'pkce check failed: no verifier provided'
        )
        return false
      elsif challenge.blank?
        update_response_for_invalid_assertion(
          response, 
          'pkce check failed: no challenge code provided'
        )
        return false
      elsif method == 'plain'
        return true unless challenge != verifier

        update_response_for_invalid_assertion(
          response, 
          "invalid plain pkce verifier: got '#{verifier}' expected '#{challenge}'"
        )
        return false
      elsif method == 'S256'
        return true unless challenge != AppRedirectTest.calculate_s256_challenge(verifier)
        update_response_for_invalid_assertion(
          response, 
          "invalid S256 pkce verifier: got '#{AppRedirectTest.calculate_s256_challenge(verifier)}' " \
          "expected '#{challenge}'"
        )
        return false
      else
        update_response_for_invalid_assertion(
          response, 
          "invalid pkce challenge method '#{method}'"
        )
        return false
      end
      
      true
    end

    def authorization_code_request_details(inferno_request)
      details_hash = 
        if inferno_request.verb.downcase == 'get'
          CGI.parse(inferno_request.url.split('?')[1])
        elsif inferno_request.verb.downcase == 'post'
          CGI.parse(inferno_request.request_body)
        else
          nil
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
