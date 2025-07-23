module SMARTAppLaunch
  class AttestationTest305 < Inferno::Test
    title 'Attestation Test 305'
    id :attestation_test_305
    description %(
[if Client supplies JWK set directly to the FHIR authorization server during registration for the `client-confidential-asymmetric`capability,] the FHIR authorization server SHALL protect the JWK Set from corruption.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@305'

    
  end
end