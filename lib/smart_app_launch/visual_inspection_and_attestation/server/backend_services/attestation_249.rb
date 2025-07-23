module SMARTAppLaunch
  class AttestationTest249 < Inferno::Test
    title 'Attestation Test 249'
    id :attestation_test_249
    description %(
The FHIR authorization server [SHALL validate] a client’s authentication JWT according to the client-confidential-asymmetric authentication profile … [per the] [JWT validation rules](https://hl7.org/fhir/smart-app-launch/STU2.2/client-confidential-asymmetric.html#signature-verification).
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@249'

    
  end
end