module SMARTAppLaunch
  class ClientJWTValidationAttestationTest < Inferno::Test
    title 'Validates a client\'s authentication JWT'
    id :client_jwt_validation
    description %(
      The server validates a client's authentication JWT according to the client-confidential-asymmetric authentication
      profile.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@249'
  end
end