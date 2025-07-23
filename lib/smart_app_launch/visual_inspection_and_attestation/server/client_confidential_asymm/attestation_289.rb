module SMARTAppLaunch
  class AttestationTest289 < Inferno::Test
    title 'Attestation Test 289'
    id :attestation_test_289
    description %(
[When supporting the  `client-confidential-asymmetric`capability a server's .well-known/smart-configuration`] configuration properties [SHALL] include ... `token_endpoint_auth_signing_alg_values_supported` (with values that include at least one of `RS384`, `ES384`).
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@289'

    
  end
end