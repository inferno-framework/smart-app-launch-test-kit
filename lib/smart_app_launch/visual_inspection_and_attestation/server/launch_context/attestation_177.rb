module SMARTAppLaunch
  class AttestationTest177 < Inferno::Test
    title 'Attestation Test 177'
    id :attestation_test_177
    description %(
{A]ny contextual resource types that were requested by a launch scope will appear in the `fhirContext` array... except ... Patient and Encounter resource types, which will not be deprecated from top-level parameters, and they will not be permitted within the `fhirContex`t array unless they include a `role` other than "launch".
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@177'

    
  end
end