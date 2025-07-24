module SMARTAppLaunch
  class FhirAuthServerAccessTokenScopeAttestationTest < Inferno::Test
    title 'Confirms scope requested is within pre-authorized client scope'
    id :fhir_auth_server_access_token_scope
    description %(
      The FHIR authorization server mediates the request to assure that the scope requested is within the scope
      pre-authorized to the client.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@250'
  end
end