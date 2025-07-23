module SMARTAppLaunch
  class AttestationTest286 < Inferno::Test
    title 'Attestation Test 286'
    id :attestation_test_286
    description %(
[When supporting the  `client-confidential-asymmetric`capability a server's .well-known/smart-configuration`] configuration properties [SHALL] include ... `token_endpoint`,
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@286'

    
  end
end