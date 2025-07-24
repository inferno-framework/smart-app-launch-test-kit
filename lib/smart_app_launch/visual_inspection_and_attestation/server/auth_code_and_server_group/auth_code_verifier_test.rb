module SMARTAppLaunch
  class AuthorizationCodeVerifierAttestationTest < Inferno::Test
    title 'Ensures that `code_verifier` is present and valid in authorization code requests'
    id :auth_code_verifier
    description %(
      The server ensure that the `code_verifier` is present and valid when the code is exchanged for an access token.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@31'
  end
end