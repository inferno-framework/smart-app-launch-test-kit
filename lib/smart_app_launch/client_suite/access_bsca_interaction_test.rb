require_relative '../urls'
require_relative '../endpoints/mock_smart_server'
require_relative 'client_descriptions'

module SMARTAppLaunch
  class SMARTClientAccessBackendServicesConfidentialAsymmetricInteraction < Inferno::Test
    include URLs
    include ClientWaitDialogDescriptions

    id :smart_client_access_bsca_interaction
    title 'Access a secured FHIR endpoint using SMART Backend Services'
    description %(
      During this test, Inferno will wait for the client to access data
      using a SMART token obtained using the Backend Services flow.
    )
    input :client_id,
          title: 'Client Id',
          type: 'text',
          locked: true,
          description: INPUT_CLIENT_ID_DESCRIPTION_LOCKED
    input :smart_jwk_set,
          title: 'JSON Web Key Set (JWKS)',
          type: 'textarea',
          locked: true,
          description: INPUT_CLIENT_JWKS_DESCRIPTION_LOCKED
    input :fhir_read_resources_bundle,
          title: 'Available Resources',
          type: 'textarea',
          optional: true,
          description: INPUT_FHIR_READ_RESOURCES_BUNDLE_DESCRIPTION
    input :echoed_fhir_response,
          title: 'Default FHIR Response',
          type: 'textarea',
          optional: true,
          description:INPUT_ECHOED_FHIR_RESPONSE_DESCRIPTION

    run do
      wait(
        identifier: client_id,
        message: wait_dialog_backend_services_access_prefix(client_id) + 
                 wait_dialog_access_response_and_continue_suffix(client_resume_pass_url, client_id)
      )
    end
  end
end
