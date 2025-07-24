module SMARTAppLaunch
  class AttestationTest310 < Inferno::Test
    title 'Attestation Test 310'
    id :attestation_test_310
    description %(
The FHIR authorization server SHALL be capable of validating signatures with at least one of `RS384` or `ES384`.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@310'

    
  end
end