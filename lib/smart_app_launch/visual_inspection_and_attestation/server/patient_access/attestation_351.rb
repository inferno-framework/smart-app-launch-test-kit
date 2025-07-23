module SMARTAppLaunch
  class AttestationTest351 < Inferno::Test
    title 'Attestation Test 351'
    id :attestation_test_351
    description %(
"[To support the ] Clinician Access for EHR Launch [Capability Set, a server SHALL support the following capabilities:]
1. `launch-ehr`
2. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
3. `context-ehr-patient` support
4. `context-ehr-encounter` support
5. `permission-user
6. `permission-patient `"
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@351'

    
  end
end