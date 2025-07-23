module SMARTAppLaunch
  class AttestationTest191 < Inferno::Test
    title 'Attestation Test 191'
    id :attestation_test_191
    description %(
The absence of a role property [in a `fhirContext` array object] is semantically equivalent to a role of `"launch"`, indicating to a client [which SHALL interpret it to mean] that the app launch was performed in the context of the referenced resource.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@191'

    
  end
end