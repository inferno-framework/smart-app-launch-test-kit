module SMARTAppLaunch
  class AttestationTest196 < Inferno::Test
    title 'Attestation Test 196'
    id :attestation_test_196
    description %(
When the `openid` scope is requested, apps can [(if a FHIR representation of the user is needed, SHALL,)] also request the `fhirUser` scope to obtain a FHIR resource representation of the current user
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@196'

    
  end
end