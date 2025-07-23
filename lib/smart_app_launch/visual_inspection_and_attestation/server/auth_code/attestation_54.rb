module SMARTAppLaunch
  class AttestationTest54 < Inferno::Test
    title 'Attestation Test 54'
    id :attestation_test_54
    description %(
The EHR decides whether to ... deny access [in response to an Authorization Request]. This decision is communicated to the app when the EHR authorization server returns … an eror response
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@54'

    
  end
end