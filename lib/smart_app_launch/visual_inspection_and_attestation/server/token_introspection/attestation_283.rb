module SMARTAppLaunch
  class AttestationTest283 < Inferno::Test
    title 'Attestation Test 283'
    id :attestation_test_283
    description %(
Clients authorized in this way [to acess an access-controlled token introspection endpoint] are [(SHALL be)] able to introspect tokens issued to any client
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@283'

    
  end
end