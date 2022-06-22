require_relative 'well_known_capabilities_stu2_test'
require_relative 'well_known_endpoint_test'

module SMARTAppLaunch
  class DiscoverySTU2Group < Inferno::TestGroup
    id :smart_discovery_stu2
    title 'SMART on FHIR Discovery'
    short_description 'Retrieve server\'s SMART on FHIR configuration.'
    description %(
      # Background

      The #{title} Sequence test looks for authorization endpoints and SMART
      capabilities as described by the [SMART App Launch
      Framework](http://hl7.org/fhir/smart-app-launch/STU2/).
      The SMART launch framework uses OAuth 2.0 to *authorize* apps, like
      Inferno, to access certain information on a FHIR server. The
      authorization service accessed at the endpoint allows users to give
      these apps permission without sharing their credentials with the
      application itself. Instead, the application receives an access token
      which allows it to access resources on the server. The access token
      itself has a limited lifetime and permission scopes associated with it.
      A refresh token may also be provided to the application in order to
      obtain another access token. Unlike access tokens, a refresh token is
      not shared with the resource server. If OpenID Connect is used, an id
      token may be provided as well. The id token can be used to
      *authenticate* the user. The id token is digitally signed and allows the
      identity of the user to be verified.

      # Test Methodology

      This test suite will examine the SMART on FHIR configuration contained
      in the `/.well-known/smart-configuration` endpoint.

      For more information see:

      * [SMART App Launch Framework](http://hl7.org/fhir/smart-app-launch/STU2/)
      * [The OAuth 2.0 Authorization Framework](https://tools.ietf.org/html/rfc6749)
      * [OpenID Connect Core](https://openid.net/specs/openid-connect-core-1_0.html)
    )

    test from: :well_known_endpoint,
         config: {
           outputs: {
             well_known_authorization_url: { name: :smart_authorization_url },
             well_known_token_url: { name: :smart_token_url }
           }
         }
    test from: :well_known_capabilities_stu2
  end
end
