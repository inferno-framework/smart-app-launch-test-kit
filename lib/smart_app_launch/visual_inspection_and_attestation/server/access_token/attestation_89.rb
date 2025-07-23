module SMARTAppLaunch
  class AttestationTest89 < Inferno::Test
    title 'Attestation Test 89'
    id :attestation_test_89
    description %(
The EHR authorization server decides ... whether to issue a refresh token, as defined in section 1.5 of [RFC6749](https://tools.ietf.org/html/rfc6749#page-10), along with the access token.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@89'

    
  end
end