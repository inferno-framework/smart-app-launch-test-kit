module SMARTAppLaunch
  class AuthenticatedTransmissionAttestationTest < Inferno::Test
    title 'Ensures transmission is ONLY to authenticated servers over TLS-secured channels'
    id :authenticated_transmission
    description %(
      The client application ensures that transmission is ONLY to authenticated servers, over TLS-secured channels when
      protocol steps include transmission of sensitive information.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@1'

    input :authenticated_transmission_correct,
          title: 'Ensures transmission is ONLY to authenticated servers over TLS-secured channels',
          description: %(
            I attest that the client application ensures that transmission is ONLY to authenticated servers, over TLS-secured
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

    run do
      assert authenticated_transmission_correct == 'true',
             'Client application does not ensure transmission is ONLY to authenticated servers over TLS-secured
              channels.'
      pass authenticated_transmission_note if authenticated_transmission_note.present?
    end
  end
end
