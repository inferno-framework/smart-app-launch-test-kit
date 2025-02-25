require 'jwt'

require_relative 'jwks'

module SMARTAppLaunch
  class ClientAssertionBuilder
    def self.build(...)
      new(...).client_assertion
    end

    attr_reader :aud,
                :client_assertion_type,
                :content_type,
                :client_auth_encryption_method,
                :exp,
                :grant_type,
                :iss,
                :jti,
                :sub,
                :kid,
                :custom_jwks

    def initialize(
      client_auth_encryption_method:,
      iss:,
      sub:,
      aud:,
      exp: 5.minutes.from_now.to_i,
      jti: SecureRandom.hex(32),
      kid: nil,
      custom_jwks: nil
    )
      @client_auth_encryption_method = client_auth_encryption_method
      @iss = iss
      @sub = sub
      @aud = aud
      @content_type = content_type
      @grant_type = grant_type
      @client_assertion_type = client_assertion_type
      @exp = exp
      @jti = jti
      @kid = kid.presence
      @custom_jwks = custom_jwks
    end

    def jwks
      @jwks ||=
        if custom_jwks.present?
          JWT::JWK::Set.new(JSON.parse(custom_jwks))
        else
          JWKS.jwks
        end
    end

    def private_key
      @private_key ||=
        jwks
          .select { |key| key[:key_ops]&.include?('sign') }
          .select { |key| key[:alg] == client_auth_encryption_method }
          .find { |key| !kid || key[:kid] == kid }
    end

    def jwt_payload
      { iss:, sub:, aud:, exp:, jti: }.compact
    end

    def signing_key
      if private_key.nil?
        raise Inferno::Exceptions::AssertionException,
              "No signing key found for inputs: encryption method = '#{client_auth_encryption_method}' and kid = '#{kid}'"
      end

      @private_key.signing_key
    end

    def key_id
      @private_key['kid']
    end

    def client_assertion
      @client_assertion ||=
        JWT.encode jwt_payload, signing_key, client_auth_encryption_method,
                   { alg: client_auth_encryption_method, kid: key_id, typ: 'JWT' }
    end
  end
end
