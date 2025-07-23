module SMARTAppLaunch
  class AttestationTest85 < Inferno::Test
    title 'Attestation Test 85'
    id :attestation_test_85
    description %(
The access token is a string of characters as defined in [RFC6749](https://tools.ietf.org/html/rfc6749) and [RFC6750](http://tools.ietf.org/html/rfc6750).
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@85'

    
  end
end