module SMARTAppLaunch
  class AttestationTest161 < Inferno::Test
    title 'Attestation Test 161'
    id :attestation_test_161
    description %(
Apps that launch from the EHR will be passed an explicit URL parameter called `launch`, whose value must associate the app’s authorization request with the current EHR session.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@161'

    
  end
end