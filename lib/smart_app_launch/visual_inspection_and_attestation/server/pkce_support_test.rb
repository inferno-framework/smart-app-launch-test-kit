module SMARTAppLaunch
  class PKCESupportAttestationTest < Inferno::Test
    title 'Follows PKCE support rules'
    id :pkce_support
    description %(
      Servers adhere to the following rules regarding PKCE:
      - Supports the `S256` `code_challenge_method`
      - Does not support the `plain` method
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@14',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@15'

    input :code_challenge_method_support,
          title: 'Supports the `S256` `code_challenge_method`',
          description: %(
            I attest that the server supports the `S256` `code_challenge_method`.
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
    input :code_challenge_method_support_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    input :plain_method_support,
          title: 'Does not support the `plain` method',
          description: %(
            I attest that the server does not support the `plain` method.
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
    input :plain_method_support_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert code_challenge_method_support == 'true',
             'Server did support the `S256` `code_challenge_method`'
      pass code_challenge_method_support_note if code_challenge_method_support_note.present?

      assert plain_method_support == 'true',
             'Server supported the `plain` method.'
      pass plain_method_support_note if plain_method_support_note.present?
    end
  end
end