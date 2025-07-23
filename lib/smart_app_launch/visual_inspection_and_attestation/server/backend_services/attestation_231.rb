module SMARTAppLaunch
  class AttestationTest231 < Inferno::Test
    title 'Attestation Test 231'
    id :attestation_test_231
    description %(
All exchanges described herein between the client and the FHIR server SHALL be secured using TLS V1.2 or a more recent version of TLS .
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@231'

    
  end
end