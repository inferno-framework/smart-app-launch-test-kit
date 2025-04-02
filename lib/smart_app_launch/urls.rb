# frozen_string_literal: true

module SMARTAppLaunch
  FHIR_PATH = '/fhir'
  RESUME_PASS_PATH = '/resume_pass'
  RESUME_FAIL_PATH = '/resume_fail'
  AUTH_SERVER_PATH = '/auth'
  SMART_DISCOVERY_PATH = "#{FHIR_PATH}/.well-known/smart-configuration".freeze
  TOKEN_PATH = "#{AUTH_SERVER_PATH}/token".freeze

  module URLs
    def client_base_url
      @base_url ||= "#{Inferno::Application['base_url']}/custom/#{client_suite_id}"
    end

    def client_fhir_base_url
      @fhir_base_url ||= client_base_url + FHIR_PATH
    end

    def client_resume_pass_url
      @resume_pass_url ||= client_base_url + RESUME_PASS_PATH
    end

    def client_resume_fail_url
      @resume_fail_url ||= client_base_url + RESUME_FAIL_PATH
    end

    def client_smart_discovery_url
      @smart_discovery_url ||= client_base_url + SMART_DISCOVERY_PATH
    end

    def client_token_url
      @token_url ||= client_base_url + TOKEN_PATH
    end

    def client_suite_id
      SMARTAppLaunch::SMARTClientSTU22Suite.id
    end
  end
end
