module SMARTAppLaunch
  class AttestationTest215 < Inferno::Test
    title 'Attestation Test 215'
    id :attestation_test_215
    description %(
To request a `refresh_token` that can be used to obtain a new access token after the current access token expires, add [the] `online_request` [scope that requests a refresh token that] … will be usable for as long as the end-user remains online.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@215'

    
  end
end