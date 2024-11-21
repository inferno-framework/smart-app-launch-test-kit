module SMARTAppLaunch
  module Feature
    class << self
      def use_auth_info?
        ENV.fetch('USE_AUTH_INFO', 'false')&.casecmp?('true')
      end
    end
  end
end
