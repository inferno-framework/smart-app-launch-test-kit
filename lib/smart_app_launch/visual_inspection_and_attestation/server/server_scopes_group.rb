require_relative 'scopes_group/access_token_scope_test'
require_relative 'scopes_group/fhir_auth_server_access_token_scope_test'
require_relative 'scopes_group/launch_scope_test'
require_relative 'scopes_group/scope_access_test'
require_relative 'scopes_group/server_scopes'

module SMARTAppLaunch
  class ServerScopesAttestationGroup < Inferno::TestGroup
    id :server_scopes_group
    title 'Scopes'

    run_as_group
    test from: :access_token_scope
    test from: :fhir_auth_server_access_token_scope
    test from: :launch_scope
    test from: :scope_access
    test from: :server_scopes
  end
end
