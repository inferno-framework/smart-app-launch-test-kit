# frozen_string_literal: true

require_relative '../urls'
require_relative '../tags'
require_relative 'mock_smart_server'

module SMARTAppLaunch
  class EchoingFHIRResponderEndpoint < Inferno::DSL::SuiteEndpoint
    def test_run_identifier
      MockSMARTServer.token_to_client_id(request.headers['authorization']&.delete_prefix('Bearer '))
    end

    def make_response
      return if response.status == 401 # set in update_result (expired token handling there)

      response.content_type = 'application/fhir+json'

      # If the tester provided a response, echo it
      # otherwise, operation outcome
      echo_response = JSON.parse(result.input_json)
        .find { |input| input['name'].include?('echoed_fhir_response') }
        &.dig('value')

      unless echo_response.present?
        response.status = 400
        response.body = FHIR::OperationOutcome.new(
          issue: FHIR::OperationOutcome::Issue.new(
            severity: 'fatal', code: 'required',
            details: FHIR::CodeableConcept.new(text: 'No response provided to echo.')
          )
        ).to_json
        return
      end

      response.status = 200
      response.body = echo_response
    end

    def update_result
      if MockSMARTServer.request_has_expired_token?(request)
        MockSMARTServer.update_response_for_expired_token(response, 'Bearer token')
        return
      end

      nil # never update for now
    end

    def tags
      [ACCESS_TAG]
    end
  end
end
