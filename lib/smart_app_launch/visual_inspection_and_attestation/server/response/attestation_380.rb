module SMARTAppLaunch
  class AttestationTest380 < Inferno::Test
    title 'Attestation Test 380'
    id :attestation_test_380
    description %(
A JSON document must be returned using the `application/json`mime type.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@380'

    
  end
end