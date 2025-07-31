module SMARTAppLaunch
  class AttestationTest336 < Inferno::Test
    title 'Attestation Test 336'
    id :attestation_test_336
    description %(
The FHIR authorization server SHALL … check that the `jti` value has not been previously encountered for the given `iss` within the maximum allowed authentication JWT lifetime (e.g., 5 minutes). This check prevents replay attacks.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@336'

    
  end
end