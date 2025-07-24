module SMARTAppLaunch
  class AttestationTest337 < Inferno::Test
    title 'Attestation Test 337'
    id :attestation_test_337
    description %(
The FHIR authorization server SHALL … ensure that the `client_id` provided is known and matches the JWT’s `iss` claim.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@337'

    
  end
end