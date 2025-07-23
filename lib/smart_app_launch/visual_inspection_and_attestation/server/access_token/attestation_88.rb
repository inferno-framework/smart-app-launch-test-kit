module SMARTAppLaunch
  class AttestationTest88 < Inferno::Test
    title 'Attestation Test 88'
    id :attestation_test_88
    description %(
The EHR authorization server decides what `expires_in` value to assign to an access token ... as defined in section 1.5 of [RFC6749](https://tools.ietf.org/html/rfc6749#page-10), along with the access token.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@88'

    
  end
end