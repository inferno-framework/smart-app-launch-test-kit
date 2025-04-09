require_relative '../../tags'
require_relative '../../urls'
require_relative '../../endpoints/mock_smart_server'

module SMARTAppLaunch
  class SMARTClientAppLaunchAuthorizationRequestVerification < Inferno::Test
    include URLs

    id :smart_client_app_launch_authorization_request_verification
    title 'Verify SMART Authorization Requests'
    description %(
        Check that SMART authorization requests are conformant.
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
    input :smart_redirect_uris,
          title: 'SMART App Launch Redirect URI(s)',
          type: 'textarea',
          description: %(
            Registered Redirect URIs in the form of a comma-separated list of one or more URIs.
            Redirect URIs specified in authorization requests must come from this list.
            Create a new session if you need to change this value.
          ),
          locked: true,
          optional: true
    input :launch_key,
          optional: true

    run do
      load_tagged_requests(AUTHORIZATION_TAG, SMART_TAG)
      skip_if requests.blank?, 'No SMART authorization requests made.'

      requests.each_with_index do |authorization_request, index|
        auth_code_request_params = MockSMARTServer.authorization_code_request_details(authorization_request)
        check_request_params(auth_code_request_params, index + 1)
      end

      
      assert messages.none? { |msg|
        msg[:type] == 'error'
      }, 'Invalid authorization requests detected. See messages for details.'
    end

    def check_request_params(params, request_num)
      if params['response_type'] != 'code'
        add_message('error',
                    "Authorization request #{request_num} had an incorrect `response_type`: expected 'code', " \
                    "but got '#{params['response_type']}'")
      end
      if params['client_id'] != client_id
        add_message('error',
                    "Authorization request #{request_num} had an incorrect `client_id`: expected #{client_id}, " \
                    "but got '#{params['client_id']}'")
      end
      if params['redirect_uri'].blank?
        add_message('error',
                    "Authorization request #{request_num} is missing the `redirect_uri` element")
      else
        if smart_redirect_uris.blank?
          add_message('error',
                      'No redirect URIs registered to check against the `redirect_uri` element ' \
                      "in authorization request #{request_num} is missing the `redirect_uri` element")
        elsif !smart_redirect_uris.split(',').include?(params['redirect_uri'])
          add_message('error',
                      "Authorization request #{request_num} had an unregistered `redirect_uri`: " \
                      "got #{params['redirect_uri']}, but expected one of '#{smart_redirect_uris}'")
        end
      end
      if launch_key.present?
        if params['launch'] != launch_key
          add_message('error',
                      "Authorization request #{request_num} had an incorrect `launch`: expected #{launch_key}, " \
                      "but got '#{params['launch']}'")
        end
      else
        if params['launch'].present?
          add_message('error',
                      "Authorization request #{request_num} for a standalone launch included `launch` but should not.")
        end
      end
      if params['state'].blank?
        add_message('error',
                    "Authorization request #{request_num} is missing the `state` element")
      end
      if params['aud'] != client_fhir_base_url
        add_message('error',
                    "Authorization request #{request_num} had an incorrect `aud`: " \
                    "expected '#{client_fhir_base_url}', but got '#{params['aud']}'")
      end
      if params['code_challenge'].blank?
        add_message('error',
                    "Authorization request #{request_num} is missing the `code_challenge` element")
      end
      if params['code_challenge_method'] != 'S256'
        add_message('error',
                    "Authorization request #{request_num} had an incorrect `aud`: " \
                    "expected 'S256', but got '#{params['code_challenge_method']}'")
      end

      return unless params['scope'].blank?

      add_message('error', "Token request #{request_num} did not include the requested `scope`")
    end

    
  end
end
