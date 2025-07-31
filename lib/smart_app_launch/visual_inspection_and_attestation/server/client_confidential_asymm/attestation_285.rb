module SMARTAppLaunch
  class AttestationTest285 < Inferno::Test
    title 'Attestation Test 285'
    id :attestation_test_285
    description %(
[A] server [SHALL advertise] its support for SMART Confidential Clients with Asymmetric Keys by including the `client-confidential-asymmetric` capability at is `.well-known/smart-configuration` endpoint; 
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@285'

    
  end
end