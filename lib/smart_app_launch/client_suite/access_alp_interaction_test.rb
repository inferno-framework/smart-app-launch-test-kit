require_relative '../urls'
require_relative '../endpoints/mock_smart_server'
require_relative 'client_descriptions'

module SMARTAppLaunch
  class SMARTClientAccessAppLaunchPublicInteraction < Inferno::Test
    include URLs
    include ClientWaitDialogDescriptions

    id :smart_client_access_alp_interaction
    title 'Access a secured FHIR endpoint using SMART App Launch'
    description %(
      During this test, Inferno will wait for the public client to access data
      using a SMART token obtained using the SMART App Launch EHR launch
      or standalone launch flow.
    )
    input :client_id,
          title: 'Client Id',
          type: 'text',
          locked: true,
          description: INPUT_CLIENT_ID_DESCRIPTION_LOCKED
    input :smart_launch_urls,
          title: 'SMART App Launch URL(s)',
          type: 'textarea',
          locked: true,
          optional: true,
          description: INPUT_SMART_LAUNCH_URLS_DESCRIPTION_LOCKED
    input :launch_context,
          title: 'Launch Context',
          type: 'textarea',
          optional: true,
          description: INPUT_LAUNCH_CONTEXT_DESCRIPTION       
    input :fhir_user_relative_reference,
          title: 'FHIR User Relative Reference',
          type: 'text',
          optional: true,
          description: INPUT_FHIR_USER_RELATIVE_REFERENCE
    input :fhir_read_resources_bundle,
          title: 'Available Resources',
          type: 'textarea',
          optional: true,
          description: INPUT_FHIR_READ_RESOURCES_BUNDLE_DESCRIPTION
    input :echoed_fhir_response,
          title: 'Default FHIR Response',
          type: 'textarea',
          optional: true,
          description: INPUT_ECHOED_FHIR_RESPONSE_DESCRIPTION

    output :launch_key

    run do
      begin
        JSON.parse(launch_context) if launch_context.present?
      rescue JSON::ParserError
        add_message(
          'warning', 
          'Input **Launch Context** is not valid JSON and will be disregarded when responding to token requests'
        )
      end

      wait(
        identifier: client_id,
        message: access_wait_dialog_app_launch_access_prefix(client_id, 'public', client_fhir_base_url) +
                 access_wait_dialog_ehr_launch_instructions(smart_launch_urls, client_fhir_base_url) +
                 access_wait_dialog_access_response_and_continue_suffix(client_id, client_resume_pass_url)
      )
    end
  end
end
