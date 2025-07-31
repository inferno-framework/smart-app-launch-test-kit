module SMARTAppLaunch
  class ServerTokenIntrospectionAttestationTest < Inferno::Test
    title 'Complies with requirements for token introspection'
    id :server_token_introspection
    description %(
      The server complies with requirements for token introspection:
      - Responds to token introspection conducted according to [RFC 7662: OAuth 2.0 Token Introspection](https://datatracker.ietf.org/doc/html/rfc7662)
      - Requires the `active` field by RFC7662 in the introspection response
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@271',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@272'

    input :server_token_introspection_correct,
          title: 'Complies with requirements for token introspection',
          description: %(
            I attest that the server complies with requirements for token introspection:
            - Responds to token introspection conducted according to [RFC 7662: OAuth 2.0 Token Introspection](https://datatracker.ietf.org/doc/html/rfc7662)
            - Requires the `active` field by RFC7662 in the introspection response
          ),
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Yes',
                value: 'true'
              },
              {
                label: 'No',
                value: 'false'
              }
            ]
          }
    input :server_token_introspection_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert server_token_introspection_correct == 'true',
             'Server does not comply with requirements for token introspection.'
      pass server_token_introspection_note if server_token_introspection_note.present?
    end
  end
end