module SMARTAppLaunch
  class AttestationTest348 < Inferno::Test
    title 'Attestation Test 348'
    id :attestation_test_348
    description %(
"[To support the ] Patient Access for Standalone Apps [Capability Set, a server SHALL support the following capabilities:]
1. `launch-standalone`
2. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
3. `context-standalone-patient`
4. `permission-patient `"
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@348'

    
  end
end