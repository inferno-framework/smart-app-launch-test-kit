module SMARTAppLaunch
  class AuthorizationServerAccessTokenExpireAttestationTest < Inferno::Test
    title 'Does not accept expired authorization tokens'
    id :auth_server_access_token_expire
    description %(
      The server does not accept expired authorization tokens from the EHR Authorization server.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@77'

    
  end
end