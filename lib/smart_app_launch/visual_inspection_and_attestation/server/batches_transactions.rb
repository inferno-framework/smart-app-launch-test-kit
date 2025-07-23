module SMARTAppLaunch
  class BatchesTransactionsAttestation < Inferno::Test
    title 'Validates batch and transaction requests with the contained requests'
    id :batches_transactions
    description %(
      Batch and transaction requests are validated based on the actual requests within them.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@130'
  end
end