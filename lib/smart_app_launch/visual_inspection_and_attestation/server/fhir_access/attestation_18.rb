module SMARTAppLaunch
  class AttestationTest18 < Inferno::Test
    title 'Attestation Test 18'
    id :attestation_test_18
    description %(
"[In the SMART APP Launch process] the complete URLs of all apps approved for use by users of this EHR [SHALL] ... have been registered with the EHR authorization server.

"
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@18'

    
  end
end