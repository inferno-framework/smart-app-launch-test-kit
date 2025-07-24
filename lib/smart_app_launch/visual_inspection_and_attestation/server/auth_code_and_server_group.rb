require_relative 'auth_code_and_server_group/auth_code_verifier_test'
require_relative 'auth_code_and_server_group/auth_server_access_token_expire_test'
require_relative 'auth_code_and_server_group/auth_server_url_registration_test'

module SMARTAppLaunch
  class AuthorizationCodeAndServerAttestationGroup < Inferno::TestGroup
    id :auth_code_and_server_group
    title 'Authorization Codes and Servers'

    run_as_group
    test from: :auth_code_verifier
    test from: :auth_server_access_token_expire
    test from: :auth_server_url_registration
  end
end