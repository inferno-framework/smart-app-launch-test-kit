require 'uri'

module SMARTAppLaunch
  class AppRedirectTest < Inferno::Test
    title 'OAuth server redirects client browser to app redirect URI'
    description %(
      Client browser redirected from OAuth server to redirect URI of client
      app as described in SMART authorization sequence.
    )
    id :smart_app_redirect

    input :client_id, :requested_scopes, :url, :smart_authorization_url
    input :use_pkce,
          title: 'Proof Key for Code Exchange (PKCE)',
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Enabled',
                value: 'true'
              },
              {
                label: 'Disabled',
                value: 'false'
              }
            ]
          }
    input :pkce_code_challenge_method,
          optional: true,
          title: 'PKCE Code Challenge Method',
          type: 'radio',
          default: 'S256',
          options: {
            list_options: [
              {
                label: 'S256',
                value: 'S256'
              },
              {
                label: 'plain',
                value: 'plain'
              }
            ]
          }

    output :state, :pkce_code_challenge, :pkce_code_verifier
    receives_request :redirect

    config options: { redirect_uri: "#{Inferno::Application['base_url']}/custom/smart/redirect" }

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
        ### #{self.class.parent.parent.title}

        [Follow this link to authorize with the SMART server](#{auth_url}).

        Tests will resume once Inferno receives a request at
        `#{config.options[:redirect_uri]}` with a state of `#{state}`.
      )
    end

    def authorization_url_builder(url, params)
      uri = URI(url)

      # because the URL might have paramters on it
      original_parameters = Hash[URI.decode_www_form(uri.query || '')]
      new_params = original_parameters.merge(params)

      uri.query = URI.encode_www_form(new_params)
      uri.to_s
    end

    run do
      assert_valid_http_uri(
        smart_authorization_url,
        "OAuth2 Authorization Endpoint '#{smart_authorization_url}' is not a valid URI"
      )

      output state: SecureRandom.uuid

      oauth2_params = {
        'response_type' => 'code',
        'client_id' => client_id,
        'redirect_uri' => config.options[:redirect_uri],
        'scope' => requested_scopes,
        'state' => state,
        'aud' => aud
      }

      if config.options[:launch]
        oauth2_params['launch'] = config.options[:launch]
      elsif self.class.inputs.include?(:launch)
        oauth2_params['launch'] = launch
      end

      if use_pkce == 'true'
        # code verifier must be between 43 and 128 characters
        code_verifier = SecureRandom.uuid + '-' + SecureRandom.uuid
        code_challenge =
          if pkce_code_challenge_method == 'S256'
            self.class.calculate_s256_challenge(code_verifier)
          else
            code_verifier
          end

        output pkce_code_verifier: code_verifier, pkce_code_challenge: code_challenge

        oauth2_params.merge!('code_challenge' => code_challenge, 'code_challenge_method' => pkce_code_challenge_method)
      end

      authorization_url = authorization_url_builder(
        smart_authorization_url,
        oauth2_params
      )

      wait(
        identifier: state,
        message: wait_message(authorization_url)
      )
    end
  end
end
