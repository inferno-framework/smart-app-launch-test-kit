module SMARTAppLaunch
  class TokenIntrospectionAttestationTest < Inferno::Test
    title 'Adheres to guidelines for token introspection support'
    id :token_introspection
    description %(
      Servers adhere to the following guidelines for token introspection support:
      - Responds to token introspection conducted according to [RFC 7662: OAuth 2.0 Token Introspection](https://datatracker.ietf.org/doc/html/rfc7662)
      - Requires the `active` field by RFC7662 in the introspection response
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@271',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@272'

    input :token_introspection_guidelines,
          title: 'Adheres to guidelines for token introspection support',
          description: %(
            I attest that the server adheres to the following guidelines for token introspection support:
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
    input :token_introspection_guidelines_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert token_introspection_guidelines == 'true',
             'Server did not adhere to guidelines for token introspection support.'
      pass token_introspection_guidelines_note if token_introspection_guidelines_note.present?
    end
  end
end