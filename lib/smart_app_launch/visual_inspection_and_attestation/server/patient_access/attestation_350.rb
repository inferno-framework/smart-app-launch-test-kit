module SMARTAppLaunch
  class AttestationTest350 < Inferno::Test
    title 'Attestation Test 350'
    id :attestation_test_350
    description %(
"[To support the ] Clinician Access for Standalone [Capability Set, a server SHALL support the following capabilities:]
1. `launch-standalone`
2. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
3. `permission-user`
4. `permission-patient `"
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@350'

    
  end
end