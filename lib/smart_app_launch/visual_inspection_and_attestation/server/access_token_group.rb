require_relative 'access_token_group/access_token_response_scope_test'
require_relative 'access_token_group/access_token_scope_validation_test'
require_relative 'access_token_group/access_token_validation_test'
require_relative 'access_token_group/short_lived_access_tokens_test'
require_relative 'access_token_group/access_token_test'

module SMARTAppLaunch
  class AccessTokenAttestationGroup < Inferno::TestGroup
    id :access_token_group
    title 'Access Tokens'

    run_as_group
    test from: :access_token_response_scope
    test from: :access_token_scope_validation
    test from: :access_token_validation
    test from: :short_lived_access_tokens
    test from: :access_token
  end
end
