require 'tls_test_kit'

module SMARTAppLaunch
  class SMARTTLSTest < TLSTestKit::TLSVersionTest
    id :smart_tls
    input :smart_auth_info, type: :auth_info, options: { mode: 'auth' }

    def url
      return super if config.options[:smart_endpoint_key].blank?

      smart_auth_info.send(config.options[:smart_endpoint_key])
    end
  end
end
