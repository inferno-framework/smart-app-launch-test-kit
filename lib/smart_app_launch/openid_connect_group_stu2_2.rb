require_relative 'openid_fhir_user_claim_stu2_2_test'
require_relative 'openid_connect_group'
require_relative 'cors_support_stu2_2_test'

module SMARTAppLaunch
  class OpenIDConnectGroupSTU22 < OpenIDConnectGroup
    id :smart_openid_connect_stu2_2
    title 'OpenID Connect'
    short_description 'Demonstrate the ability to authenticate users with OpenID Connect.'

    description %(
      # Background

      OpenID Connect (OIDC) provides the ability to verify the identity of the
      authorizing user. Within the [SMART App Launch
      Framework](https://www.hl7.org/fhir/smart-app-launch/STU2.2/), Applications can
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

      * [SMART App Launch Framework](https://www.hl7.org/fhir/smart-app-launch/STU2.2/)
      * [Scopes for requesting identity data](https://www.hl7.org/fhir/smart-app-launch/STU2.2/scopes-and-launch-context/index.html#scopes-for-requesting-identity-data)
      * [Apps Requesting Authorization](https://www.hl7.org/fhir/smart-app-launch/STU2.2/index.html#step-1-app-asks-for-authorization)
      * [OpenID Connect Core](https://openid.net/specs/openid-connect-core-1_0.html)
    )
    test from: :smart_openid_fhir_user_claim_stu2_2

    fhir_user_claim_index = children.find_index { |child| child.id.to_s.end_with? 'fhir_user_claim' }
    children[fhir_user_claim_index] = children.pop

    test from: :smart_cors_support_stu2_2,
         title: 'SMART FHIR User REST API Endpoint Enables Cross-Origin Resource Sharing (CORS)',
         description: %(
           For requests from a client's registered origin(s), CORS configuration permits access to the token endpoint
           and to FHIR REST API endpoints. This test verifies that a request to the FHIR REST API endpoint for the FHIR
           user is returned with the appropriate CORS header.
         ),
         config: {
           requests: {
             cors_request: { name: :fhir_user }
           }
         }
  end
end
