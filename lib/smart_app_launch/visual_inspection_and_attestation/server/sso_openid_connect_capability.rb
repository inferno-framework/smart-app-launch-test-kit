module SMARTAppLaunch
  class SsoOpenIdConnectCapabilityAttestation < Inferno::Test
    title ''
    id :sso_openid_connect_capability
    description %(
      - Supports the Authorization Code Flow, with the request parameters as defined in SMART App Launch to be
        considered compatible with the SMART sso-openid-connect capability
      - Supports the inclusion of SMART's `fhirUser` claim within the `id_token` issued for any requests that grant the
        `openid` and `fhirUser` scopes
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@205',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@209'
  end
end