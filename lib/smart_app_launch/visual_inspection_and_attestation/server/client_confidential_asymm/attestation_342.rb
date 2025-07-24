module SMARTAppLaunch
  class AttestationTest342 < Inferno::Test
    title 'Attestation Test 342'
    id :attestation_test_342
    description %(
The FHIR authorization server SHOULD cache a client’s JWK Set according to the client’s cache-control header; it doesn’t need to retrieve it anew every time. 
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@342'

    
  end
end