module SMARTAppLaunch
  class AttestationTest201 < Inferno::Test
    title 'Attestation Test 201'
    id :attestation_test_201
    description %(
This token must be [validated according to the OIDC specification](http://openid.net/specs/openid-connect-core-1_0.html#IDTokenValidation) [by the client app].
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@201'

    
  end
end