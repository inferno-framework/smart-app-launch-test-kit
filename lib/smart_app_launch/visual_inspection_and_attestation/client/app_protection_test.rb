module SMARTAppLaunch
  class AppProtectionAttestationTest < Inferno::Test
    title 'Complies with requirements for app protection'
    id :app_protection
    description %(
      Client applications perform app protection by:
      - Ensuring that transmission is ONLY to authenticated servers, over TLS-secured channels when protocol steps
        include transmission of sensitive information
      - Generating an unpredictable `state` parameter for each use session
      - Validates the `state` value for any request sent to its redirect URL
      - Does not execute untrusted user-supplied inputs as code
      - Does not forward values passed back to its redirect URL
      - Does not store bearer tokens in cookies
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@1',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@2',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@4',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@5',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@6',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@7'

    input :authenticated_transmission,
          title: 'Ensures transmission is ONLY to authenticated servers over TLS-secured channels',
          description: %(
            I attest that the client application ensures transmission is ONLY to authenticated servers over TLS-secured
            channels when protocol steps include transmission of sensitive information.
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
    input :authenticated_transmission_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    input :state_param,
          title: 'Generates and validates an unpredictable `state` parameter for each use session',
          description: %(
            I attest that the client application generates an unpredictable `state` parameter for each use session and
            validates the `state` value or any request sent to its redirect URL.
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
    input :state_param_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    input :app_protection_rules,
          title: 'Does not execute, store, or forward anything that undermines app protection',
          description: %(
            I attest that the client application does not:
            - Execute untrusted user-supplied inputs as code
            - Forward values passed back to its redirect URL
            - Store bearer tokens in cookies
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
    input :app_protection_rules_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert authenticated_transmission == 'true',
             'Client application did not ensure transmission is ONLY to authenticated servers over TLS-secured
              channels.'
      pass authenticated_transmission_note if authenticated_transmission_note.present?

      assert state_param == 'true',
             'Client application did not generate and validate an unpredictable `state` parameter for each use session.'
      pass state_param_note if state_param_note.present?

      assert app_protection_rules == 'true',
             'Client application executed, stored, or forwarded something that undermines app protection.'
      pass app_protection_rules_note if app_protection_rules_note.present?
    end
  end
end
