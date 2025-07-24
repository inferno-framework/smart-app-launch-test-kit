require_relative 'authorization_code_request_group/http_post_get_test'
require_relative 'authorization_code_request_group/id_token_scopes_test'
require_relative 'authorization_code_request_group/launch_param_omit_test'
require_relative 'authorization_code_request_group/state_param_require_test'
require_relative 'authorization_code_request_group/state_param_auth_code_validation_test'

module SMARTAppLaunch
  class AuthorizationCodeRequestAttestationGroup < Inferno::TestGroup
    id :authorization_code_request_group
    title 'Authorization Code Requests'

    run_as_group
    test from: :http_post_get
    test from: :id_token_scopes
    test from: :launch_param_omit
    test from: :state_param_require
    test from: :state_param_auth_code_validation
  end
end
