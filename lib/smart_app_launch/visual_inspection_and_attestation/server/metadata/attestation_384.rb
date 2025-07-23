module SMARTAppLaunch
  class AttestationTest384 < Inferno::Test
    title 'Attestation Test 384'
    id :attestation_test_384
    description %(
[When responding to a `/.well-known/smart-configuration` request the] ...Metadata ...`grant_types_supported`[is] required … [and Shall contain the] Array of grant types supported at the token endpoint. The options are “authorization_code” (when SMART App Launch is supported) and “client_credentials” (when SMART Backend Services is supported).
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@384'

    
  end
end