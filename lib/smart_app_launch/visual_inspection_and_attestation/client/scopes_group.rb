require_relative 'scopes_group/openid_scopes_uri_test'
require_relative 'scopes_group/scope_requests_test'
require_relative 'scopes_group/scopes_test'
require_relative 'scopes_group/smart_scopes_uri_test'

module SMARTAppLaunch
  class ScopesAttestationGroup < Inferno::TestGroup
    id :scopes_group
    title 'Scopes'

    run_as_group
    test from: :openid_scopes_uri
    test from: :scope_requests
    test from: :scopes
    test from: :smart_scopes_uri
  end
end
