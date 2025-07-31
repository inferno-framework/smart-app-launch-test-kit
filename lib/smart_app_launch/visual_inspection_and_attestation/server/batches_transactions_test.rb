module SMARTAppLaunch
  class BatchesTransactionsAttestationTest < Inferno::Test
    title 'Validates batch and transaction requests with the contained requests'
    id :batches_transactions
    description %(
      The server ensures that batch and transaction requests are validated based on the actual requests within them.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@130'

    input :batches_transactions_correct,
          title: 'Validates batch and transaction requests with the contained requests',
          description: %(
            I attest that the server ensures that batch and transaction requests are validated based on the actual
            requests within them.
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
    input :batches_transactions_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert batches_transactions_correct == 'true',
             'Server does not validate batch and transaction requests with the contained requests.'
      pass batches_transactions_note if batches_transactions_note.present?
    end
  end
end
