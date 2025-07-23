module SMARTAppLaunch
  class AttestationTest211 < Inferno::Test
    title 'Attestation Test 211'
    id :attestation_test_211
    description %(
To be considered compatible with the SMART’s sso-openid-connect capability, … A SMART app SHALL NOT pass the `auth_time` claim or `max_age` parameter to a server that does not support receiving them.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@211'

    
  end
end