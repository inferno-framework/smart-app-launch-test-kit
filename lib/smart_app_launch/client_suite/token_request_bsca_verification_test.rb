require_relative '../tags'
require_relative '../urls'
require_relative '../endpoints/mock_smart_server'
require_relative 'authentication_verification'
require_relative 'client_descriptions'
require_relative 'client_options'
require_relative 'token_request_verification'


module SMARTAppLaunch
  class SMARTClientTokenRequestBackendServicesConfidentialAsymmetricVerification < Inferno::Test
    include URLs
    include AuthenticationVerification
    include TokenRequestVerification

    id :smart_client_token_request_bsca_verification
    title 'Verify SMART Token Requests'
    description %(
        Check that SMART token requests are conformant.
      )

    input :client_id,
          title: 'Client Id',
          type: 'text',
          locked: true,
          description: INPUT_CLIENT_ID_DESCRIPTION_LOCKED
    input :smart_jwk_set,
          title: 'JSON Web Key Set (JWKS)',
          type: 'textarea',
          locked: true,
          description: INPUT_CLIENT_JWKS_DESCRIPTION_LOCKED
    
    output :smart_tokens

    run do
      load_tagged_requests(TOKEN_TAG, SMART_TAG, CLIENT_CREDENTIALS_TAG)
      skip_if requests.blank?, 'No SMART token requests made.'

      verify_token_requests(CLIENT_CREDENTIALS_TAG, CONFIDENTIAL_ASYMMETRIC_TAG)

      assert messages.none? { |msg|
        msg[:type] == 'error'
      }, 'Invalid token requests detected. See messages for details.'
    end
  end
end
