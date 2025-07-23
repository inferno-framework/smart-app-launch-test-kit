module SMARTAppLaunch
  class AttestationTest24 < Inferno::Test
    title 'Attestation Test 24'
    id :attestation_test_24
    description %(
"The EHR confirms the app’s registration parameters and communicates a `client_id` to the app.
"
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@24'

    
  end
end