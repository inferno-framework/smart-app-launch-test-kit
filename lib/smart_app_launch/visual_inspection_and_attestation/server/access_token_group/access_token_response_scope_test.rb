module SMARTAppLaunch
  class AccessTokenResponseScopeAttestationTest < Inferno::Test
    title 'Allows access token response `scope` to differ from requested scopes'
    id :access_token_response_scope
    description %(
      The server responds with an access token where the `scope` parameter value can be different from the scopes
      requested by the app.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@259'
  end
end