module SMARTAppLaunch
  class AttestationTest378 < Inferno::Test
    title 'Attestation Test 378'
    id :attestation_test_378
    description %(
[In responses for `/.well-known/smart-configuration` requests] All endpoint URLs in the response document SHALL be absolute URLs.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@378'

    
  end
end