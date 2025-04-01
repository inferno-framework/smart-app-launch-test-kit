# frozen_string_literal: true

module SMARTAppLaunch
  FHIR_PATH = '/fhir'
  RESUME_PASS_PATH = '/resume_pass'
  RESUME_FAIL_PATH = '/resume_fail'
  AUTH_SERVER_PATH = '/auth'
  SMART_DISCOVERY_PATH = "#{FHIR_PATH}/.well-known/smart-configuration".freeze
  TOKEN_PATH = "#{AUTH_SERVER_PATH}/token".freeze

  module URLs
    def base_url
      @base_url ||= "#{Inferno::Application['base_url']}/custom/#{suite_id}"
    end

    def fhir_base_url
      @fhir_base_url ||= base_url + FHIR_PATH
    end

    def resume_pass_url
      @resume_pass_url ||= base_url + RESUME_PASS_PATH
    end

    def resume_fail_url
      @resume_fail_url ||= base_url + RESUME_FAIL_PATH
    end

    def smart_discovery_url
      @smart_discovery_url ||= base_url + SMART_DISCOVERY_PATH
    end

    def token_url
      @token_url ||= base_url + TOKEN_PATH
    end

    def suite_id
      self.class.suite.id
    end
  end
end
