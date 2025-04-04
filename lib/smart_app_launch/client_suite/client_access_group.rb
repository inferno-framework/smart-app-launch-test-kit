require_relative 'client_access_interaction_test'
require_relative 'client_token_request_verification_test'
require_relative 'client_token_use_verification_test'

module SMARTAppLaunch
  class SMARTClientAccess < Inferno::TestGroup
    id :smart_client_access
    title 'Client Access'
    description %(
      During these tests, the client system will access Inferno's simulated
      FHIR server by requesting an access token and making a FHIR request.
      Inferno will then verify that any token requests made were conformant
      and that a token returned from a token request was used on an access request.
    )

    run_as_group

    input :smart_jwk_set,
          optional: true,
          locked: true

    test from: :smart_client_access_interaction
    test from: :smart_client_token_request_verification
    test from: :smart_client_token_use_verification
  end
end
