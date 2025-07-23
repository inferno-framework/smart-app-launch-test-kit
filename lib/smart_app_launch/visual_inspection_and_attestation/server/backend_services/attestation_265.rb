module SMARTAppLaunch
  class AttestationTest265 < Inferno::Test
    title 'Attestation Test 265'
    id :attestation_test_265
    description %(
The resource server SHALL validate the access token and ensure that it has not expired
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@265'

    
  end
end