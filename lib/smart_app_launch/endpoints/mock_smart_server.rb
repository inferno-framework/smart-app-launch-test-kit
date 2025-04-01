require 'jwt'
require 'faraday'
require 'time'
require_relative '../urls'
require_relative '../tags'

module SMARTAppLaunch
  module MockSMARTServer
    include Inferno::DSL::HTTPClient
    SUPPORTED_SCOPES = ['openid', 'system/*.read', 'user/*.read', 'patient/*.read'].freeze

    module_function

    def smart_server_metadata(env)
      base_url = env_base_url(env, SMART_DISCOVERY_PATH)
      response_body = {
        token_endpoint_auth_signing_alg_values_supported: ['RS384', 'ES384'],
        capabilities: ['client-confidential-asymmetric'],
        code_challenge_methods_supported: ['S256'],
        token_endpoint_auth_methods_supported: ['private_key_jwt'],
        issuer: base_url + FHIR_PATH,
        grant_types_supported: ['client_credentials'],
        scopes_supported: SUPPORTED_SCOPES,
        token_endpoint: base_url + TOKEN_PATH
      }.to_json

      [200, { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*' }, [response_body]]
    end

    def env_base_url(env, endpoint_path)
      protocol = env['rack.url_scheme']
      host = env['HTTP_HOST']
      path = env['REQUEST_PATH'] || env['PATH_INFO']
      path.gsub!(%r{#{endpoint_path}(/)?}, '')
      "#{protocol}://#{host + path}"
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

    def token_to_client_id(token)
      decode_token(token)&.dig('client_id')
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
      decoded_token = decode_token(token)
      return false unless decoded_token&.dig('expiration').present?

      decoded_token['expiration'] < Time.now.to_i
    end

    def update_response_for_expired_token(response)
      response.status = 401
      response.format = :json
      response.body = FHIR::OperationOutcome.new(
        issue: FHIR::OperationOutcome::Issue.new(severity: 'fatal', code: 'expired',
                                                 details: FHIR::CodeableConcept.new(text: 'Bearer token has expired'))
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
  end
end
