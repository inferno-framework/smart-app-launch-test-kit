module SMARTAppLaunch
  class TokenIntrospectionAttestationTest < Inferno::Test
    title 'Makes requests according to Token Introspection'
    id :token_introspection
    description %(
      The client application conducts token introspection and makes requests according to [RFC 7662: OAuth 2.0 Token
      Introspection](https://datatracker.ietf.org/doc/html/rfc7662).
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@270'

    input :token_introspection_correct,
          title: 'Makes requests according to Token Introspection',
          description: %(
            I attest that the client application conducts token introspection and makes requests according to
            [RFC 7662: OAuth 2.0 Token Introspection](https://datatracker.ietf.org/doc/html/rfc7662).
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
    input :token_introspection_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert token_introspection_correct == 'true',
             'Client application did not make requests according to Token Introspection.'
      pass token_introspection_note if token_introspection_note.present?
    end
  end
end
