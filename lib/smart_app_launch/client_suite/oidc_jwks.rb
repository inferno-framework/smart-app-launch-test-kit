require 'jwt'

module SMARTAppLaunch
  class OIDCJWKS
    class << self
      def jwks_json
        @jwks_json ||=
          JSON.pretty_generate(
            { keys: jwks.export[:keys].select { |key| key[:key_ops]&.include?('verify') } }
          )
      end

      def default_jwks_path
        @default_jwks_path ||= File.join(__dir__, 'oidc_jwks.json')
      end

      def jwks_path
        @jwks_path ||=
          ENV.fetch('SIMULATED_OIDC_JWKS_PATH', default_jwks_path)
      end

      def jwks
        @jwks ||= JWT::JWK::Set.new(JSON.parse(File.read(jwks_path)))
      end
    end
  end
end
