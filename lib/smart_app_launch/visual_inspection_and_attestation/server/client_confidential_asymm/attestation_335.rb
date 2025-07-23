module SMARTAppLaunch
  class AttestationTest335 < Inferno::Test
    title 'Attestation Test 335'
    id :attestation_test_335
    description %(
The FHIR authorization server SHALL validate the JWT according to the processing requirements defined in [Section 3 of RFC7523](https://tools.ietf.org/html/rfc7523#section-3) including validation of the signature on the JWT
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@335'

    
  end
end