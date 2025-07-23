module SMARTAppLaunch
  class AttestationTest164 < Inferno::Test
    title 'Attestation Test 164'
    id :attestation_test_164
    description %(
If an application requests a FHIR Resource scope which is restricted to a single patient (e.g., patient/*.rs), and the authorization results in the EHR granting that scope, the EHR SHALL establish a patient in context. 
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@164'

    
  end
end