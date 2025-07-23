module SMARTAppLaunch
  class AttestationTest228 < Inferno::Test
    title 'Attestation Test 228'
    id :attestation_test_228
    description %(
Servers [SHALL] respond  [to requests to [base]/.well-known/smart-configuration] with a discovery response that meets [discovery requirements described in `client-confidential-asymmetric` authentication](https://hl7.org/fhir/smart-app-launch/STU2.2/client-confidential-asymmetric.html#discovery-requirements).  [from [base]/.well-known/smart-configuration]
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@228'

    
  end
end