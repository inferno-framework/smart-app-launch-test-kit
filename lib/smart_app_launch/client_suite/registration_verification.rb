module SMARTAppLaunch
  module RegistrationVerification
    def verify_registered_jwks(jwks_input)

      jwks_warnings = []
      parsed_smart_jwk_set = MockSMARTServer.jwk_set(smart_jwk_set, jwks_warnings)
      jwks_warnings.each { |warning| add_message('warning', warning) }

      # TODO: add key-specific verification per end of https://build.fhir.org/ig/HL7/smart-app-launch/client-confidential-asymmetric.html#registering-a-client-communicating-public-keys

      unless parsed_smart_jwk_set.length.positive?
        add_message(
          'error',
          'JWKS content for Confidential Asymmetric authentication does not include any valid keys.'
        )
      end
    end

    def verify_registered_launch_urls(launch_urls)
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

    def verify_registered_redirect_uris(redirect_uris)
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