module SMARTAppLaunch
  class AttestationTest349 < Inferno::Test
    title 'Attestation Test 349'
    id :attestation_test_349
    description %(
"[To support the ] Patient Access for EHR Launch (i.e. from Portal) [Capability Set, a server SHALL support the following capabilities:]
1.` launch-ehr`
2. At least one of `client-public` or `client-confidential-symmetric`; and MAY support `client-confidential-asymmetric`
3.`context-ehr-patient`
4. `permission-patient`"
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@349'

    
  end
end