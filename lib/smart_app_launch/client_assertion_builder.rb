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
                :encryption_method,
                :exp,
                :grant_type,
                :iss,
                :jti,
                :sub

    def initialize(
      encryption_method:,
      iss:,
      sub:,
      aud:,
      exp: 5.minutes.from_now.to_i,
      jti: SecureRandom.hex(32)
    )
      @encryption_method = encryption_method
      @iss = iss
      @sub = sub
      @aud = aud
      @content_type = content_type
      @grant_type = grant_type
      @client_assertion_type = client_assertion_type
      @exp = exp
      @jti = jti
    end

    def private_key
      @private_key ||=
        JWKS.jwks
          .find { |key| key[:key_ops]&.include?('sign') && key[:alg] == encryption_method }
    end

    def jwt_payload
      { iss:, sub:, aud:, exp:, jti: }.compact
    end

    def kid
      private_key.kid
    end

    def signing_key
      private_key.signing_key
    end

    def client_assertion
      @client_assertion ||=
        JWT.encode jwt_payload, signing_key, encryption_method, { alg: encryption_method, kid:, typ: 'JWT' }
    end
  end
end
