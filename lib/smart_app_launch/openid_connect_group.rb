require 'jwt'
require_relative 'openid_decode_id_token_test'
require_relative 'openid_retrieve_configuration_test'
require_relative 'openid_required_configuration_fields_test'
require_relative 'openid_retrieve_jwks_test'
require_relative 'openid_token_header_test'
require_relative 'openid_token_payload_test'
require_relative 'openid_fhir_user_claim_test'

module SMARTAppLaunch
  class OpenIDConnectGroup < Inferno::TestGroup
    id :smart_openid_connect
    title 'OpenID Connect'

    description %(
      # Background

      OpenID Connect (OIDC) provides the ability to verify the identity of the
      authorizing user. Within the [SMART App Launch
      Framework](http://hl7.org/fhir/smart-app-launch/), Applications can
      request an `id_token` be provided with by including the `openid fhirUser`
      scopes when requesting authorization.

      # Test Methodology

      This sequence validates the id token returned as part of the OAuth 2.0
      token response. Once the token is decoded, the server's OIDC configuration
      is retrieved from its well-known configuration endpoint. This
      configuration is checked to ensure that all required fields are present.
      Next the keys used to cryptographically sign the id token are retrieved
      from the url contained in the OIDC configuration. Then the header,
      payload, and signature of the id token are validated. Finally, the FHIR
      resource from the `fhirUser` claim in the id token is fetched from the
      FHIR server.

      For more information see:

      * [SMART App Launch Framework](http://hl7.org/fhir/smart-app-launch/)
      * [Scopes for requesting identity data](http://hl7.org/fhir/smart-app-launch/scopes-and-launch-context/index.html#scopes-for-requesting-identity-data)
      * [Apps Requesting Authorization](http://hl7.org/fhir/smart-app-launch/#step-1-app-asks-for-authorization)
      * [OpenID Connect Core](https://openid.net/specs/openid-connect-core-1_0.html)
    )

    test from: :smart_openid_decode_id_token

    test from: :smart_openid_retrieve_configuration

    test from: :smart_openid_required_configuration_fields

    test from: :smart_openid_retrieve_jwks

    test from: :smart_openid_token_header

    test from: :smart_openid_token_payload

    test from: :smart_openid_fhir_user_claim
  end
end
