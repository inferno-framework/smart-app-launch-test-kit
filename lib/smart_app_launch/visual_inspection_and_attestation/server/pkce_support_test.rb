module SMARTAppLaunch
  class PKCESupportAttestationTest < Inferno::Test
    title 'Complies with requirements for PKCE support'
    id :pkce_support
    description %(
      The server complies with requirements for PKCE support:
      - Supports the `S256` `code_challenge_method`
      - Does not support the `plain` method
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@14',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@15'

    input :pkce_support_correct,
          title: 'Complies with requirements for PKCE support',
          description: %(
            I attest that the server complies with requirements for PKCE support:
            - Supports the `S256` `code_challenge_method`
            - Does not support the `plain` method
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
    input :pkce_support_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert pkce_support_correct == 'true',
             'Server does not comply with requirements for PKCE support.'
      pass pkce_support_note if pkce_support_note.present?
    end
  end
end