module SMARTAppLaunch
  class TLSExchangeAttestationTest < Inferno::Test
    title 'Secures exchanges between the client using TLS V1.2 or higher'
    id :tls_exchange
    description %(
      The server secures exchanges between the client using TLS V1.2 or a more recent version of TLS.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@231'

    input :tls_exchange_correct,
          title: 'Secures exchanges between the client using TLS V1.2 or higher',
          description: %(
            I attest that the server secures exchanges between the client using TLS V1.2 or a more recent version of
            TLS.
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
    input :tls_exchange_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert tls_exchange_correct == 'true',
             'Server does not secure exchanges between the client using TLS V1.2 or higher.'
      pass tls_exchange_note if tls_exchange_note.present?
    end
  end
end
