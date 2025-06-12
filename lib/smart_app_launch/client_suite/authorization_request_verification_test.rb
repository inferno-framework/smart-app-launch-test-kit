require_relative '../tags'
require_relative '../urls'
require_relative '../endpoints/mock_smart_server'
require_relative 'client_descriptions'

module SMARTAppLaunch
  class SMARTClientAppLaunchAuthorizationRequestVerification < Inferno::Test
    include URLs

    id :smart_client_authorization_request_verification
    title 'Verify SMART App Launch Authorization Requests'
    description %(
      Check that SMART authorization requests made are conformant.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@32',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@33',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@34',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@35',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@37',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@39',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@40',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@41',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@44',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@45'

    input :client_id,
          title: 'Client Id',
          type: 'text',
          locked: true,
          description: INPUT_CLIENT_ID_DESCRIPTION_LOCKED
    input :smart_redirect_uris,
          title: 'SMART App Launch Redirect URI(s)',
          type: 'textarea',
          locked: true,
          description: INPUT_SMART_REDIRECT_URIS_DESCRIPTION_LOCKED
    input :launch_key,      # from app launch access interaction test, 
          optional: true    # present if client registered for ehr launch but won't know if did ehr or standalone
          
    def client_suite_id
      return config.options[:endpoint_suite_id] if config.options[:endpoint_suite_id].present?

      SMARTAppLaunch::SMARTClientSTU22Suite.id
    end
    
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
      # for ehr launch, `launch` value must be the one Inferno generated
      # but can't know if this was intended to be ehr or standalone if `launch` isn't there
      # and currently the tests allow either standalone or ehr launch
      if launch_key.present? && params['launch'].present? && params['launch'] != launch_key
        add_message('error',
                    "Authorization request #{request_num} had an incorrect `launch`: expected #{launch_key}, " \
                    "but got '#{params['launch']}'")
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
                    "Authorization request #{request_num} had an incorrect `code_challenge_method`: " \
                    "expected 'S256', but got '#{params['code_challenge_method']}'")
      end
      if params['scope'].blank?
        add_message('error', "Token request #{request_num} did not include the requested `scope`")
      end

      nil
    end
  end
end
