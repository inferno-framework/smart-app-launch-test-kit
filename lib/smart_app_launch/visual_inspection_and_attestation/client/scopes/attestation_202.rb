module SMARTAppLaunch
  class AttestationTest202 < Inferno::Test
    title 'Attestation Test 202'
    id :attestation_test_202
    description %(
To learn more about the user, the app should  treat the `fhirUser` claim as the URL of a FHIR resource representing the current user [and SHALL perform a FHIR read interaction to get it].
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@202'

    
  end
end