# frozen_string_literal: true

require_relative '../tags'

module SMARTAppLaunch
  module SMARTClientOptions
    module_function

    SMART_APP_LAUNCH_PUBLIC = "#{SMART_TAG},#{AUTHORIZATION_CODE_TAG},#{PUBLIC_TAG}".freeze
    SMART_APP_LAUNCH_CONFIDENTIAL_SYMMETRIC = 
      "#{SMART_TAG},#{AUTHORIZATION_CODE_TAG},#{CONFIDENTIAL_SYMMETRIC_TAG}".freeze
    SMART_APP_LAUNCH_CONFIDENTIAL_ASYMMETRIC = 
      "#{SMART_TAG},#{AUTHORIZATION_CODE_TAG},#{CONFIDENTIAL_ASYMMETRIC_TAG}".freeze
    SMART_BACKEND_SERVICES_CONFIDENTIAL_ASYMMETRIC =
      "#{SMART_TAG},#{CLIENT_CREDENTIALS_TAG},#{CONFIDENTIAL_ASYMMETRIC_TAG}".freeze

    def oauth_flow(suite_options)
      if suite_options[:client_type].include?(AUTHORIZATION_CODE_TAG)
        AUTHORIZATION_CODE_TAG
      elsif suite_options[:client_type].include?(CLIENT_CREDENTIALS_TAG)
        CLIENT_CREDENTIALS_TAG
      end
    end

    def smart_authentication_approach(suite_options)
      if suite_options[:client_type].include?(PUBLIC_TAG)
        PUBLIC_TAG
      elsif suite_options[:client_type].include?(CONFIDENTIAL_SYMMETRIC_TAG)
        CONFIDENTIAL_SYMMETRIC_TAG
      elsif suite_options[:client_type].include?(CONFIDENTIAL_ASYMMETRIC_TAG)
        CONFIDENTIAL_ASYMMETRIC_TAG
      end
    end
  end
end
