module SMARTAppLaunch
  class AttestationTest59 < Inferno::Test
    title 'Attestation Test 59'
    id :attestation_test_59
    description %(
[When] the EHR authorization server causes the browser to navigate to the app’s redirect_uri … [the] `state` [parameter is] required [and SHALL contain t]he exact value received from the client [in parameter of the same name on the authorization request]. 
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@59'

    
  end
end