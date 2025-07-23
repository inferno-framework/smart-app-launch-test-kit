module SMARTAppLaunch
  class AttestationTest166 < Inferno::Test
    title 'Attestation Test 166'
    id :attestation_test_166
    description %(
Standalone apps that launch outside the EHR do not have any EHR context at the outset. These apps must explicitly request EHR context. 
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@166'

    
  end
end