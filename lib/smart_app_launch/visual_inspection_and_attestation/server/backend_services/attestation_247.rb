module SMARTAppLaunch
  class AttestationTest247 < Inferno::Test
    title 'Attestation Test 247'
    id :attestation_test_247
    description %(
Rules regarding circumstances under which a client is required to obtain and present an access token along with a request are based on risk-management decisions that each FHIR resource service needs to [(SHALL)] make, considering the workflows involved, perceived risks, and the organization’s risk-management policies.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@247'

    
  end
end