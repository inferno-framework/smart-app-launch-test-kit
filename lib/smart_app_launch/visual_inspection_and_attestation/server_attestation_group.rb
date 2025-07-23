require_relative 'server/backend_scopes_test'
require_relative 'server/batches_transactions_test'
require_relative 'server/brand_bundle_population_test'
require_relative 'server/capability_support_test'
require_relative 'server/fhir_server_brand_bundles_test'
require_relative 'server/launch_context_authorization_test'
require_relative 'server/launch_context_paramters_test'
require_relative 'server/pkce_support_test'
require_relative 'server/refresh_access_tokens_test'
require_relative 'server/scope_access_test'
require_relative 'server/sso_openid_connect_capability_test'

module SMARTAppLaunch
  class ServerAttestationGroupSTU22 < Inferno::TestGroup
    id :smart_server_visual_inspection_and_attestation_stu2_2

    title 'Visual Inspection and Attestation'

    description <<~DESCRIPTION
      Perform visual inspections or attestations to ensure that the Server is conformant to the SMART App Launch IG requirements.
    DESCRIPTION

    run_as_group
    test from: :backend_services_scopes
    test from: :batches_transactions
    test from: :brand_bundle_population
    test from: :server_capabilities
    test from: :fhir_server_brand_bundles
    test from: :launch_context_authorization
    test from: :launch_context_parameters
    test from: :pkce_support
    test from: :refresh_access_tokens
    test from: :scope_access
    test from: :sso_openid_connect_capability
  end
end