require_relative 'client/access_token_request_test'
require_relative 'client/brand_bundles_test'
require_relative 'client/client_confidential_asymmetric_test'
require_relative 'client/context_data_request_test'
require_relative 'client/fhir_request_auth_header_test'
require_relative 'client/id_token_use_test'
require_relative 'client/public_keys_test'
require_relative 'client/refresh_tokens_test'
require_relative 'client/token_introspection_test'
require_relative 'client/app_launch_group'
require_relative 'client/app_protection_group'
require_relative 'client/authorization_code_request_group'
require_relative 'client/fhir_authorization_server_group'
require_relative 'client/scopes_group'
require_relative 'client/smart_configuration_group'

module SMARTAppLaunch
  class ClientAttestationGroupSTU22 < Inferno::TestGroup
    id :smart_client_visual_inspection_and_attestation_stu2_2

    title 'Visual Inspection and Attestation'

    description <<~DESCRIPTION
      Perform visual inspections or attestations to ensure that the Client is conformant to the SMART App Launch IG requirements.
    DESCRIPTION

    run_as_group
    group from: :app_launch_group
    group from: :app_protection_group
    group from: :authorization_code_request_group
    group from: :fhir_auth_server_group
    group from: :scopes_group
    group from: :smart_configuration_group
    test from: :access_token_request
    test from: :brand_bundles
    test from: :client_confidential_asymmetric
    test from: :context_data_requests
    test from: :fhir_request_authorization_header
    test from: :id_token_use
    test from: :public_keys
    test from: :refresh_tokens
    test from: :token_introspection
  end
end
