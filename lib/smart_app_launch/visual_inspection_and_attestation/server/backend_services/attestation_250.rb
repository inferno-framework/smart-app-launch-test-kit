module SMARTAppLaunch
  class AttestationTest250 < Inferno::Test
    title 'Attestation Test 250'
    id :attestation_test_250
    description %(
Once the client has been authenticated, the FHIR authorization server SHALL mediate the request to assure that the scope requested is within the scope pre-authorized to the client.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@250'

    
  end
end