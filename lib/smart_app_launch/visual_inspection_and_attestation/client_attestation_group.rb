require_relative 'client/access_token_request_test'
require_relative 'client/app_protection_test'
require_relative 'client/authorization_code_request_test'
require_relative 'client/brand_bundles_test'
require_relative 'client/context_data_request_test'
require_relative 'client/fhir_auth_server_test'
require_relative 'client/fhir_request_auth_header_test'
require_relative 'client/public_keys_test'
require_relative 'client/refresh_tokens_test'
require_relative 'client/scope_requests_test'
require_relative 'client/scopes_test'
require_relative 'client/smart_configuration_test'
require_relative 'client/token_introspection_test'

module SMARTAppLaunch
  class ClientAttestationGroupSTU22 < Inferno::TestGroup
    id :smart_client_visual_inspection_and_attestation_stu2_2

    title 'Visual Inspection and Attestation'

    description <<~DESCRIPTION
      Perform visual inspections or attestations to ensure that the Client is conformant to the SMART App Launch IG requirements.
    DESCRIPTION

    run_as_group
    test from: :access_token_request
    test from: :app_protection
    test from: :authorization_code_request
    test from: :brand_bundles
    test from: :context_data_requests
    test from: :fhir_authorization_server
    test from: :fhir_request_authorization_header
    test from: :public_keys
    test from: :refresh_tokens
    test from: :scope_requests
    test from: :scopes
    test from: :smart_configuration
    test from: :token_introspection
  end
end