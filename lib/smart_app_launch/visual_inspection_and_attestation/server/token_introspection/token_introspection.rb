module SMARTAppLaunch
  class TokenIntrospection < Inferno::Test
    title ''
    id :token_introspection
    description %(
      - Conducted and responded to according to [RFC 7662: OAuth 2.0 Token Introspection](https://datatracker.ietf.org/doc/html/rfc7662)
      - Requires the `active` field by RFC7662 in the introspection response
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@271',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@272'
  end
end