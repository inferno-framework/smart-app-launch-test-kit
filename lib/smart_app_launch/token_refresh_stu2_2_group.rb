require_relative 'token_refresh_stu2_group'
require_relative 'cors_support_stu2_2_test'
require_relative 'token_refresh_stu2_2_test'

module SMARTAppLaunch
  class TokenRefreshSTU22Group < TokenRefreshSTU2Group
    id :smart_token_refresh_stu2_2
    title 'SMART Token Refresh'
    short_description 'Demonstrate the ability to exchange a refresh token for an access token.'
    description %(
      # Background

      The #{title} Sequence tests the ability of the system to successfully
      exchange a refresh token for an access token. Refresh tokens are typically
      longer lived than access tokens and allow client applications to obtain a
      new access token Refresh tokens themselves cannot provide access to
      resources on the server.

      Token refreshes are accomplished through a `POST` request to the token
      exchange endpoint as described in the [SMART App Launch
      Framework](https://www.hl7.org/fhir/smart-app-launch/STU2.2/index.html#step-5-later-app-uses-a-refresh-token-to-obtain-a-new-access-token).

      # Test Methodology

      This test attempts to exchange the refresh token for a new access token
      and verify that the information returned contains the required fields and
      uses the proper headers.

      For more information see:

      * [The OAuth 2.0 Authorization
        Framework](https://tools.ietf.org/html/rfc6749)
      * [Using a refresh token to obtain a new access
        token](https://www.hl7.org/fhir/smart-app-launch/STU2.2/index.html#step-5-later-app-uses-a-refresh-token-to-obtain-a-new-access-token)
    )

    test from: :smart_token_refresh_stu2_2

    token_refresh_index = children.find_index { |child| child.id.to_s.end_with? 'smart_token_refresh_stu2' }
    children[token_refresh_index] = children.pop

    test from: :cors_support_stu2_2,
         title: 'SMART Token Endpoint Enables Cross-Origin Resource Sharing (CORS)',
         description: %(
                For requests from a client's registered origin(s), CORS configuration permits access to the token
                endpoint. This test verifies that the token endpoint contains the appropriate CORS header in the
                response.
              ),
         config: {
           requests: {
             cors_request: { name: :token_refresh }
           }
         }
  end
end
