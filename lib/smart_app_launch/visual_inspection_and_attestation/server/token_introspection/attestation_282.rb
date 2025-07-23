module SMARTAppLaunch
  class AttestationTest282 < Inferno::Test
    title 'Attestation Test 282'
    id :attestation_test_282
    description %(
If access control is implemented [on the token introspection endpoint], any client authorized to issue Token Introspection API calls SHALL be permitted to authenticate to the Token Introspection endpoint by providing an appropriately-scoped SMART App or SMART Backend Service bearer token in the Authorization header. 
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@282'

    
  end
end