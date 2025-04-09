require_relative '../tags'
require_relative '../urls'
require_relative '../endpoints/mock_smart_server'
require_relative 'authentication_verification'

module SMARTAppLaunch
  class SMARTClientTokenRequestVerification < Inferno::Test
    include URLs
    include AuthenticationVerification

    id :smart_client_token_request_verification
    title 'Verify SMART Token Requests'
    description %(
        Check that SMART token requests are conformant.
      )

    input :client_id,
          title: 'Client Id',
          type: 'text',
          optional: false,
          locked: true,
          description: %(
            The registered Client Id for use in obtaining access tokens.
            Create a new session if you need to change this value.
          )
    input :smart_jwk_set,
          title: 'JSON Web Key Set (JWKS)',
          type: 'textarea',
          optional: false,
          locked: true,
          description: %(
            The SMART client's JSON Web Key Set in the form of either a publicly accessible url
            containing the JWKS, or the raw JWKS JSON. Must include the key(s) Inferno will need to
            verify signatures on token requests made by the client.
            Create a new session if you need to change this value.
          )
    output :smart_tokens

    run do
      omit_if smart_jwk_set.blank?, # for re-use: mark the smart_jwk_set input as optional when importing to enable
              'SMART Backend Services authentication not demonstrated as a part of this test session.'

      load_tagged_requests(TOKEN_TAG, SMART_TAG, CLIENT_CREDENTIAL_TAG)
      skip_if requests.blank?, 'No SMART token requests made.'

      jti_list = []
      token_list = []
      requests.each_with_index do |token_request, index|
        request_params = URI.decode_www_form(token_request.request_body).to_h
        check_request_params(request_params, index + 1)
        check_client_assertion(request_params['client_assertion'], index + 1, jti_list)
        token_list << MockSMARTServer.extract_token_from_response(token_request)
      end

      output smart_tokens: token_list.compact.join("\n")

      assert messages.none? { |msg|
        msg[:type] == 'error'
      }, 'Invalid token requests detected. See messages for details.'
    end

    def check_request_params(params, request_num)
      if params['grant_type'] != 'client_credentials'
        add_message('error',
                    "Token request #{request_num} had an incorrect `grant_type`: expected 'client_credentials', " \
                    "but got '#{params['grant_type']}'")
      end
      if params['client_assertion_type'] != 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
        add_message('error',
                    "Token request #{request_num} had an incorrect `client_assertion_type`: " \
                    "expected 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer', " \
                    "but got '#{params['client_assertion_type']}'")
      end
      return unless params['scope'].blank?

      add_message('error', "Token request #{request_num} did not include the requested `scope`")
    end
  end
end
