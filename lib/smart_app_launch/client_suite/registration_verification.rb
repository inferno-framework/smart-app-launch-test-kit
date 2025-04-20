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

      normalized_launch_urls = normalize_urls(launch_urls, 'launch URL')
      output smart_launch_urls: normalized_launch_urls.join(',').strip
    end

    def verify_registered_redirect_uris(redirect_uris)
      return unless redirect_uris.present?

      normalized_redirect_uris = normalize_urls(redirect_uris, 'redirect URI')

      output smart_redirect_uris: normalized_redirect_uris.join(',').strip
    end

    def normalize_urls(url_list, type_for_error)
      normalized_urls = []
      url_list.split(',').map { |one_url| one_url.strip }.each do |url|
        next if url.blank?

        parsed_uri =
          begin
            URI.parse(url)
          rescue URI::InvalidURIError
            add_message('error', "Registered #{type_for_error} '#{url}' is not a valid URI.")
            nil
          end
        next unless parsed_uri.present?
        unless parsed_uri.scheme == 'https' || parsed_uri.scheme == 'http'
          add_message('error', "Registered #{type_for_error} '#{url}' is not a valid http address.")
          next
        end

        normalized_urls << url
        unless parsed_uri.scheme == 'https'
          add_message('error', "Registered #{type_for_error} '#{url}' is not a valid https URI.")
        end
      end

      normalized_urls
    end
  end
end