require_relative 'url_helpers'

module SMARTAppLaunch
  class WellKnownEndpointTest < Inferno::Test
    include URLHelpers

    title 'FHIR server makes SMART configuration available from well-known endpoint'
    id :well_known_endpoint
    description %(
      The authorization endpoints accepted by a FHIR resource server can
      be exposed as a Well-Known Uniform Resource Identifier
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@373',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@374',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@377'

    input :url,
          title: 'FHIR Endpoint',
          description: 'URL of the FHIR endpoint used by SMART applications'
    input :smart_auth_info,
          type: :auth_info

    output :well_known_configuration,
           :well_known_authorization_url,
           :well_known_introspection_url,
           :well_known_management_url,
           :well_known_registration_url,
           :well_known_revocation_url,
           :well_known_token_url,
           :smart_auth_info
    makes_request :smart_well_known_configuration

    run do
      well_known_configuration_url = "#{url.chomp('/')}/.well-known/smart-configuration"
      get(well_known_configuration_url,
          name: :smart_well_known_configuration,
          headers: { 'Accept' => 'application/json' })
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

      if smart_auth_info.use_discovery
        smart_auth_info.auth_url = well_known_authorization_url
        smart_auth_info.token_url = well_known_token_url

        output smart_auth_info: smart_auth_info
      end

      content_type = request.response_header('Content-Type')&.value

      assert content_type.present?, 'No `Content-Type` header received.'
      assert content_type.start_with?('application/json'),
             "`Content-Type` must be `application/json`, but received: `#{content_type}`"
    end
  end
end
