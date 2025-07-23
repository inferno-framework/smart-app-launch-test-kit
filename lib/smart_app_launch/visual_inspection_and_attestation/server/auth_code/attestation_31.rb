module SMARTAppLaunch
  class AttestationTest31 < Inferno::Test
    title 'Attestation Test 31'
    id :attestation_test_31
    description %(
"[When] the app constructs a request for an authorization code … the EHR SHALL ensure that the `code_verifier` is present and valid when the code is exchanged for an access token.

"
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@31'

    
  end
end