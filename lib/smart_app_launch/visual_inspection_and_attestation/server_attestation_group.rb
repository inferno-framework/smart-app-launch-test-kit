require_relative 'server/batches_transactions_test'
require_relative 'server/capability_support_test'
require_relative 'server/json_response_test'
require_relative 'server/pkce_support_test'
require_relative 'server/refresh_access_tokens_test'
require_relative 'server/registration_client_id_test'
require_relative 'server/sso_openid_connect_capability_test'
require_relative 'server/server_token_introspection_test'
require_relative 'server/well_known_smart_config_request_test'
require_relative 'server/access_token_group'
require_relative 'server/auth_code_and_server_group'
require_relative 'server/backend_services_group'
require_relative 'server/brand_bundles_group'
require_relative 'server/launch_context_group'
require_relative 'server/patient_clinician_access_group'
require_relative 'server/server_scopes_group'

module SMARTAppLaunch
  class ServerAttestationGroupSTU22 < Inferno::TestGroup
    id :smart_server_visual_inspection_and_attestation_stu2_2

    title 'Visual Inspection and Attestation'

    description <<~DESCRIPTION
      Perform visual inspections or attestations to ensure that the Server is conformant to the SMART App Launch IG requirements.
    DESCRIPTION

    run_as_group
    group from: :access_token_group
    group from: :auth_code_and_server_group
    group from: :backend_services_group
    group from: :brand_bundles_group
    group from: :launch_context_group
    group from: :patient_clinician_access_group
    group from: :server_scopes_group
    test from: :batches_transactions
    test from: :server_capabilities
    test from: :json_response
    test from: :pkce_support
    test from: :refresh_access_tokens
    test from: :registration_client_id
    test from: :sso_openid_connect_capability
    test from: :server_token_introspection
    test from: :well_known_smart_config_request
  end
end