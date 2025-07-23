module SMARTAppLaunch
  class AttestationTest77 < Inferno::Test
    title 'Attestation Test 77'
    id :attestation_test_77
    description %(
[When the EHR Authorization servers autorization token expires] the token SHALL NOT be accepted by the resource server
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@77'

    
  end
end