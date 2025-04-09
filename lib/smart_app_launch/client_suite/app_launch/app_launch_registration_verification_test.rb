require_relative '../../tags'
require_relative '../../endpoints/mock_smart_server'

module SMARTAppLaunch
  class SMARTClientAppLaunchRegistrationVerification < Inferno::Test

    id :smart_client_app_launch_registration_verification
    title 'Verify SMART App Launch Registration'
    description %(
      During this test, Inferno will verify that the SMART registration details
      provided are conformant.
    )
    
    input :client_id,
          title: 'Client Id',
          type: 'text',
          optional: true,
          description: %(
            If a particular client id is desired, put it here. Otherwise a
            default of the Inferno session id will be used.
          )
    input :smart_launch_urls,
          title: 'SMART App Launch URL(s)',
          type: 'textarea',
          description: %(
            A comma-separated list of zero or more URLs that Inferno can use to
            launch the app. Not needed if the app does not support EHR launch.
          ),
          optional: true
    input :smart_redirect_uris,
          title: 'SMART App Launch Redirect URI(s)',
          type: 'textarea',
          description: %(
            A comma-separated list of one or more URIs that the app will sepcify
            as the target of the redirect for Inferno to use when providing the authorization
            code. These tests can be run without this input, but will not pass without it.
          ),
          optional: true
    input :smart_jwk_set,
          title: 'SMART Confidential Asymmetric JSON Web Key Set (JWKS)',
          type: 'textarea',
          description: %(
            For confidential asymmetric clients, provide the JSON Web Key Set that will be used
            to sign tokens including the key(s) Inferno will need to
            verify signatures on token requests made by the client. May be provided as either
            a publicly accessible url containing the JWKS, or the raw JWKS JSON. Leave
            blank for public and confidential symmetric clients.
          ),
          optional: true
    input :smart_client_secret,
          title: 'SMART Confidential Symmetric Client Secret',
          type: 'textarea',
          description: %(
            For confidential symmetric clients, provide the client secret that will be provided
            during token requests to authenticate the client to Inferno. Leave
            blank for public and confidential asymmetric clients.
          ),
          optional: true
    

    output :client_id
    output :client_type
    output :smart_launch_urls # normalized
    output :smart_redirect_uris # normalized

    run do
      if client_id.blank?
        client_id = test_session_id
        output(client_id:)
      end

      verify_launch_urls(smart_launch_urls)
      verify_redirect_uris(smart_redirect_uris)
      verify_authentication_inputs(smart_jwk_set, smart_client_secret)

      assert messages.none? { |msg| msg[:type] == 'error' },
             'Invalid registration details provided. See messages for details'
    end

    def verify_authentication_inputs(jwks_input, client_secret_input)
      client_type = 'public'
      
      if jwks_input.present?
        jwks_warnings = []
        parsed_smart_jwk_set = MockSMARTServer.jwk_set(smart_jwk_set, jwks_warnings)
        jwks_warnings.each { |warning| add_message('warning', warning) }

        if parsed_smart_jwk_set.length.positive?
          client_type = :confidential_asymmetric
        else
          add_message(
            'error',
            'JWKS content for Confidential Asymmetric authentication does not include any valid keys. ' \
            'Confidential Asymmetric authentication will not be used.'
          )
        end
        # TODO: add key-specific verification per end of https://build.fhir.org/ig/HL7/smart-app-launch/client-confidential-asymmetric.html#registering-a-client-communicating-public-keys
      end

      if client_secret_input.present?
        if (client_type == :confidential_asymmetric)
          add_message(
            'info',
            'The tester provided valid inputs to register as both a Confidential Asymmetric and ' \
            'a Confidentials Symmetric app. Inferno will assume that the app will use the preferred ' \
            'Confidential Asymmetric authentication approach.'
          )
        else
          client_type = :confidential_symmetric
        end
      end

      output(client_type:)
    end

    def verify_launch_urls(launch_urls)
      return unless launch_urls.present?

      normalized_launch_urls = []
      launch_urls.split(',').map { |url| url.strip }.each do |launch_url|
        next if launch_url.blank?

        parsed_url =
          begin
            URI.parse(launch_url)
          rescue URI::InvalidURIError
            add_message('error', "Registered launch URL '#{launch_url}' is not a valid URI.")
            nil
          end
        next unless parsed_url.present?

        normalized_launch_urls << launch_url
        unless parsed_url.scheme == 'https'
          add_message('error', "Registered launch URL '#{launch_url}' is not a valid https URL.")
        end
      end

      output smart_launch_urls: normalized_launch_urls.join(',').strip
    end

    def verify_redirect_uris(redirect_uris)
      return unless redirect_uris.present?

      normalized_redirect_uris = []
      redirect_uris.split(',').map { |url| url.strip }.each do |redirect_uri|
        next if redirect_uri.blank?

        parsed_uri =
          begin
            URI.parse(redirect_uri)
          rescue URI::InvalidURIError
            add_message('error', "Registered redirect URI '#{redirect_uri}' is not a valid URI.")
            nil
          end
        next unless parsed_uri.present?

        normalized_redirect_uris << redirect_uri
        unless parsed_uri.scheme == 'https'
          add_message('error', "Registered redirect URI '#{redirect_uri}' is not a valid https URI.")
        end
      end

      output smart_redirect_uris: normalized_redirect_uris.join(',').strip
    end
  end
end
