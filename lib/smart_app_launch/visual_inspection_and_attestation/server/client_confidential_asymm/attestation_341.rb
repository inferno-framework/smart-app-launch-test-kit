module SMARTAppLaunch
  class AttestationTest341 < Inferno::Test
    title 'Attestation Test 341'
    id :attestation_test_341
    description %(
The FHIR authorization server SHALL NOT cache a JWKS for longer than the client’s cache-control header indicates.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@341'

    
  end
end