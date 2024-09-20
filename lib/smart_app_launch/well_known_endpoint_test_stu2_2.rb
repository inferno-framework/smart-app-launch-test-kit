require_relative 'url_helpers'

module SMARTAppLaunch
  class WellKnownEndpointSTU22Test < Inferno::Test
    include URLHelpers

    title 'FHIR server makes SMART configuration available from well-known endpoint'
    id :well_known_endpoint_stu2_2
    description %(
      The authorization endpoints accepted by a FHIR resource server can
      be exposed as a Well-Known Uniform Resource Identifier.

      For requests from any origin, CORS configuration permits access to the public discovery endpoints
      (.well-known/smart-configuration and metadata). This test verifies that the .well-known/smart-configuration
      request is returned with the appropriate CORS header.
    )
    input :url,
          title: 'FHIR Endpoint',
          description: 'URL of the FHIR endpoint used by SMART applications'
    output :well_known_configuration,
           :well_known_authorization_url,
           :well_known_introspection_url,
           :well_known_management_url,
           :well_known_registration_url,
           :well_known_revocation_url,
           :well_known_token_url
    makes_request :smart_well_known_configuration

    run do
      well_known_configuration_url = "#{url.chomp('/')}/.well-known/smart-configuration"
      inferno_origin = Inferno::Application['base_url']
      get(well_known_configuration_url,
          name: :smart_well_known_configuration,
          headers: { 'Accept' => 'application/json',
                     'Origin' => inferno_origin })
      assert_response_status(200)

      assert_valid_json(request.response_body)

      base_url = "#{url.chomp('/')}/"
      config = JSON.parse(request.response_body)

      if config['introspection_endpoint'].present?
        output well_known_introspection_url: make_url_absolute(base_url, config['introspection_endpoint'])
      end

      output well_known_configuration: request.response_body,
             well_known_authorization_url: make_url_absolute(base_url, config['authorization_endpoint']),
             well_known_management_url: make_url_absolute(base_url, config['management_endpoint']),
             well_known_registration_url: make_url_absolute(base_url, config['registration_endpoint']),
             well_known_revocation_url: make_url_absolute(base_url, config['revocation_endpoint']),
             well_known_token_url: make_url_absolute(base_url, config['token_endpoint'])

      cors_allow_origin = request.response_header('Access-Control-Allow-Origin')&.value
      assert cors_allow_origin.present?, 'No `Access-Control-Allow-Origin` header received.'
      assert cors_allow_origin == inferno_origin,
             "`Access-Control-Allow-Origin` must be `#{inferno_origin}`, but received: `#{cors_allow_origin}`"

      content_type = request.response_header('Content-Type')&.value

      assert content_type.present?, 'No `Content-Type` header received.'
      assert content_type.start_with?('application/json'),
             "`Content-Type` must be `application/json`, but received: `#{content_type}`"
    end
  end
end
