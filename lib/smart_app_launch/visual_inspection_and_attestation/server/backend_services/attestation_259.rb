module SMARTAppLaunch
  class AttestationTest256 < Inferno::Test
    title 'Attestation Test 256'
    id :attestation_test_256
    description %(
[When responding with an access token t]he `scope` [parameter value] can be different from the scopes requested by the app.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@256'

    
  end
end