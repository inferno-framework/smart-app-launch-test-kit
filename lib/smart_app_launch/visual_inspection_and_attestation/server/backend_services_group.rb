require_relative 'backend_services_group/client_jwt_validation_test'
require_relative 'backend_services_group/tls_exchange_test'

module SMARTAppLaunch
  class BackendServicesAttestationGroup < Inferno::TestGroup
    id :backend_services_group
    title 'Backend Services'

    run_as_group
    test from: :client_jwt_validation
    test from: :tls_exchange
  end
end