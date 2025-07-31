require_relative 'fhir_authorization_server_group/fhir_auth_access_token_test'
require_relative 'fhir_authorization_server_group/fhir_auth_server_auth_tls_test'

module SMARTAppLaunch
  class FhirAuthorizationServerAttestationGroup < Inferno::TestGroup
    id :fhir_auth_server_group
    title 'FHIR Authorization Server'

    run_as_group
    test from: :fhir_auth_server_access_token
    test from: :fhir_auth_server_auth_tls
  end
end
