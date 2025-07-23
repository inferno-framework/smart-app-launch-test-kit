module SMARTAppLaunch
  class AttestationTest339 < Inferno::Test
    title 'Attestation Test 339'
    id :attestation_test_339
    description %(
To retrieve the keys from a JWKS URL ... a FHIR authorization server [SHALL issue] a HTTP GET request for that URL to obtain a JWKS response.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@339'

    
  end
end