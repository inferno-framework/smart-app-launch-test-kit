module SMARTAppLaunch
  class AttestationTest216 < Inferno::Test
    title 'Attestation Test 216'
    id :attestation_test_216
    description %(
To request a `refresh_token` that can be used to obtain a new access token after the current access token expires, add [the] `offline_access`[Scope that requests a refresh token] … that will remain usable for as long as the authorization server and end-user will allow, regardless of whether the end-user is online.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@216'

    
  end
end