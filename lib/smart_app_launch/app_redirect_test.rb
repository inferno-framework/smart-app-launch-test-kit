require 'uri'

module SMARTAppLaunch
  class AppRedirectTest < Inferno::Test
    title 'OAuth server redirects client browser to app redirect URI'
    description %(
      Client browser redirected from OAuth server to redirect URI of client
      app as described in SMART authorization sequence.
    )
    id :smart_app_redirect

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@32',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@33',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@34',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@37',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@39',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@41',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@44',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@45'

    input :url
    input :smart_auth_info, type: :auth_info, options: { mode: 'auth' }
    output :state, :pkce_code_challenge, :pkce_code_verifier
    receives_request :redirect

    def default_redirect_uri
      "#{Inferno::Application['base_url']}/custom/smart/redirect"
    end

    def redirect_uri
      config.options[:redirect_uri].presence || default_redirect_uri
    end

    def self.calculate_s256_challenge(verifier)
      Base64.urlsafe_encode64(Digest::SHA256.digest(verifier), padding: false)
    end

    def aud
      url
    end

    def wait_message(auth_url)
      if config.options[:redirect_message_proc].present?
        return instance_exec(auth_url, &config.options[:redirect_message_proc])
      end

      %(
        ### #{self.class.parent&.parent&.title}

        [Follow this link to authorize with the SMART server](#{auth_url}).

        Tests will resume once Inferno receives a request at
        `#{redirect_uri}` with a state of `#{state}`.
      )
    end

    def authorization_url_builder(url, params)
      uri = URI(url)

      # because the URL might have parameters on it
      original_parameters = URI.decode_www_form(uri.query || '').to_h
      new_params = original_parameters.merge(params)

      uri.query = URI.encode_www_form(new_params)
      uri.to_s
    end

    run do
      assert_valid_http_uri(
        smart_auth_info.auth_url,
        "OAuth2 Authorization Endpoint '#{smart_auth_info.auth_url}' is not a valid URI"
      )

      output state: SecureRandom.uuid

      oauth2_params = {
        'response_type' => 'code',
        'client_id' => smart_auth_info.client_id,
        'redirect_uri' => redirect_uri,
        'scope' => smart_auth_info.requested_scopes,
        'state' => state,
        'aud' => aud
      }

      if config.options[:launch]
        oauth2_params['launch'] = config.options[:launch]
      elsif self.class.inputs.include?(:launch)
        oauth2_params['launch'] = launch
      end

      if smart_auth_info.pkce_enabled?
        # code verifier must be between 43 and 128 characters
        code_verifier = "#{SecureRandom.uuid}-#{SecureRandom.uuid}"
        code_challenge =
          if smart_auth_info.s256_code_challenge_method?
            self.class.calculate_s256_challenge(code_verifier)
          else
            code_verifier
          end

        output pkce_code_verifier: code_verifier, pkce_code_challenge: code_challenge

        oauth2_params.merge!('code_challenge' => code_challenge,
                             'code_challenge_method' => smart_auth_info.pkce_code_challenge_method)
      end

      authorization_url = authorization_url_builder(
        smart_auth_info.auth_url,
        oauth2_params
      )

      info("Inferno redirecting browser to #{authorization_url}.")

      wait(
        identifier: state,
        message: wait_message(authorization_url)
      )
    end
  end
end
