module SMARTAppLaunch
  class AccessTokenValidationAttestationTest < Inferno::Test
    title 'Validates the access token and ensures that it has not expired'
    id :access_token_validation
    description %(
      The server validates the access token and ensures that it has not expired.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@265'
  end
end