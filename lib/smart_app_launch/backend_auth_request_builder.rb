require 'json/jwt'
require_relative 'client_assertion_builder'

module SMARTAppLaunch
  class BackendServicesAuthorizationRequestBuilder
    def self.build(...)
      new(...).authorization_request
    end

    attr_reader :encryption_method, :scope, :iss, :sub, :aud, :content_type, :grant_type, :client_assertion_type, :exp,
                :jti, :kid

    def initialize(
      encryption_method:,
      scope:,
      iss:,
      sub:,
      aud:,
      content_type: 'application/x-www-form-urlencoded',
      grant_type: 'client_credentials',
      client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
      exp: 5.minutes.from_now,
      jti: SecureRandom.hex(32),
      kid: nil
    )
      @encryption_method = encryption_method
      @scope = scope
      @iss = iss
      @sub = sub
      @aud = aud
      @content_type = content_type
      @grant_type = grant_type
      @client_assertion_type = client_assertion_type
      @exp = exp
      @jti = jti
      @kid = kid
    end

    def authorization_request_headers
      {
        content_type:,
        accept: 'application/json'
      }.compact
    end

    def authorization_request_query_values
      {
        'scope' => scope,
        'grant_type' => grant_type,
        'client_assertion_type' => client_assertion_type,
        'client_assertion' => client_assertion.to_s
      }.compact
    end

    def client_assertion
      @client_assertion ||= ClientAssertionBuilder.build(
          client_auth_encryption_method: encryption_method, 
          iss: iss,
          sub: sub,
          aud: aud,
          kid: kid
          )
    end

    def authorization_request
      uri = Addressable::URI.new
      uri.query_values = authorization_request_query_values

      { body: uri.query, headers: authorization_request_headers }
    end
  end
end
