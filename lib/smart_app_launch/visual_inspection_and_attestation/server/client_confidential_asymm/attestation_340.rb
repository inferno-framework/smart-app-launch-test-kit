module SMARTAppLaunch
  class AttestationTest340 < Inferno::Test
    title 'Attestation Test 340'
    id :attestation_test_340
    description %(
If an error is encountered during the authentication process, the server SHALL respond with an `invalid_client error` as defined by the [OAuth 2.0 specification](https://tools.ietf.org/html/rfc6749#section-5.2).
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@340'

    
  end
end