module SMARTAppLaunch
  class AttestationTest288 < Inferno::Test
    title 'Attestation Test 288'
    id :attestation_test_288
    description %(
[When supporting the  `client-confidential-asymmetric`capability a server's .well-known/smart-configuration`] configuration properties [SHALL] include ...`token_endpoint_auth_methods_supported` (with values that include `private_key_jwt`)
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@288'

    
  end
end