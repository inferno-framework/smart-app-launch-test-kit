module SMARTAppLaunch
  class OpenIDScopesURIAttestationTest < Inferno::Test
    title 'Represents OpenID scopes as URIs with a prefix'
    id :openid_scopes_uri
    description %(
      The client application uses the prefix `http://openid.net/specs/openid-connect-core-1_0#` to represent OpenID
      scopes as URIs.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@220'
  end
end
