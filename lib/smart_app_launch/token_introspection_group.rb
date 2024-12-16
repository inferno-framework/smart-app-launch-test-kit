require_relative 'token_introspection_access_token_group'
require_relative 'token_introspection_response_group'
require_relative 'token_introspection_request_group'

module SMARTAppLaunch
  class SMARTTokenIntrospectionGroup < Inferno::TestGroup
    title 'Token Introspection'
    id :smart_token_introspection
    description %(
      # Background

      OAuth 2.0 Token introspection, as described in [RFC-7662](https://datatracker.ietf.org/doc/html/rfc7662), allows
      an authorized resource server to query an OAuth 2.0 authorization server for metadata on a token.  The
      [SMART App Launch STU2 Implementation Guide Section on Token Introspection](https://hl7.org/fhir/smart-app-launch/STU2/token-introspection.html)
      states that "SMART on FHIR EHRs SHOULD support token introspection, which allows a broader ecosystem of resource servers
      to leverage authorization decisions managed by a single authorization server."

      # Test Methodology

      In these tests, Inferno acts as an authorized resource server that queries the authorization server about an access
      token, rather than a client to a FHIR resource server as in the previous SMART App Launch tests.
      Ideally, Inferno should be registered with the authorization server as an authorized resource server
      capable of accessing the token introspection endpoint through client credentials, per the SMART IG recommendations.
      However, the SMART IG only formally REQUIRES "some form of authorization" to access
      the token introspection endpoint and does not specifiy any one specific approach.  As such, the token introspection tests are
      broken up into three groups that each complete a discrete step in the token introspection process:

      1. **Request Access Token Group** - optional but recommended, repeats a subset of Standalone Launch tests
        in order to receive a new access token with an authorization code grant.  If skipped, testers will need to
          obtain an access token out-of-band and manually provide values from the access token response as inputs to
          the Validate Token Response group.
      2. **Issue Token Introspection Request Group** - optional but recommended, completes the introspection requests.
      If skipped, testers will need to complete an introspection request out-of-band and manually provide the introspection
      responses as inputs to the Validate Token Response group.
      3. **Validate Token Introspection Response Group** - required, validates the contents of the introspection responses.

      Running all three test groups in order is the simplest and is highly recommended if the environment under test
      can support it, as outputs from one group will feed the inputs of the next group. However, test groups can be run
      independently if needed.

      See the individual test groups for more details and guidance.
    )
    group from: :smart_token_introspection_access_token_group
    group from: :smart_token_introspection_request_group
    group from: :smart_token_introspection_response_group

    input_order :url, :standalone_smart_auth_info, :custom_authorization_header,
                :optional_introspection_request_params

    input_instructions %(
      Executing tests at this level will run all three Token Introspection groups back-to-back.  If test groups need
      to be run independently, exit this window and select a specific test group instead.

      These tests are currently designed such that the token introspection URL must be present in the SMART well-known endpoint.

      If the introspection endpoint is protected, testers must enter their own HTTP Authorization header for the introspection request.  See
      [RFC 7616 The 'Basic' HTTP Authentication Scheme](https://datatracker.ietf.org/doc/html/rfc7617) for the most common
      approach that uses client credentials.  Testers may also provide any additional parameters needed for their authorization
      server to complete the introspection request.

      **Note:** For both the Authorization header and request parameters, user-input
      values will be sent exactly as entered and therefore the tester must
      URI-encode any appropriate values.
    )
  end
end
