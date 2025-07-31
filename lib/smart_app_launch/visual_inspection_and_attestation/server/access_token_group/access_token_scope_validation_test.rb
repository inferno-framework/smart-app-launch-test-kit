module SMARTAppLaunch
  class AccessTokenScopeValidationAttestationTest < Inferno::Test
    title 'Validates the access token and ensures its scope covers the requested resource'
    id :access_token_scope_validation
    description %(
      The server validates the access token and ensures that its scope covers the requested resource.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@266'
  end
end