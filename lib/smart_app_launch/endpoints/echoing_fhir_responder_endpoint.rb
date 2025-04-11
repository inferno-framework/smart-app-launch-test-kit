# frozen_string_literal: true

require_relative '../urls'
require_relative '../tags'
require_relative 'mock_smart_server'

module SMARTAppLaunch
  class EchoingFHIRResponderEndpoint < Inferno::DSL::SuiteEndpoint
    def test_run_identifier
      MockSMARTServer.issued_token_to_client_id(request.headers['authorization']&.delete_prefix('Bearer '))
    end

    def make_response
      return if response.status == 401 # set in update_result (expired token handling there)

      response.content_type = 'application/fhir+json'
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.status = 200

      # look for read of provided resources
      read_response = tester_provided_read_response_body
      if read_response.present?
        response.body = read_response.to_json
        return
      end

      # If the tester provided a response, echo it
      # otherwise, operation outcome
      echo_response = JSON.parse(result.input_json)
        .find { |input| input['name'].include?('echoed_fhir_response') }
        &.dig('value')
      if echo_response.present?
        response.body = echo_response
        return
      end
      
      response.status = 400
      response.body = FHIR::OperationOutcome.new(
        issue: FHIR::OperationOutcome::Issue.new(
          severity: 'fatal', code: 'required',
          details: FHIR::CodeableConcept.new(text: 'No response provided to echo.')
        )
      ).to_json  
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

    def tester_provided_read_response_body
      resource_type = request.params[:one]
      id = request.params[:two]

      return unless resource_type.present? && id.present?
      
      resource_type_class = 
        begin
          FHIR.const_get(resource_type)
        rescue NameError
          nil
        end
      return unless resource_type_class.present?

      resource_bundle = ehr_input_bundle
      return unless resource_bundle.present?

      find_resource_in_bundle(resource_bundle, resource_type_class, id)
    end

    def ehr_input_bundle
      ehr_bundle_input = 
        JSON.parse(result.input_json).find { |input| input['name'] == 'fhir_read_resources_bundle' }&.dig('value')
      ehr_bundle = FHIR.from_contents(ehr_bundle_input) if ehr_bundle_input.present?
      return ehr_bundle if ehr_bundle.is_a?(FHIR::Bundle)
      
      nil
    rescue StandardError
      nil
    end

    def find_resource_in_bundle(bundle, resource_type_class, id)
      bundle.entry&.find do |entry|
        entry.resource.is_a?(resource_type_class) && entry.resource.id == id
      end&.resource
    end
  end
end
