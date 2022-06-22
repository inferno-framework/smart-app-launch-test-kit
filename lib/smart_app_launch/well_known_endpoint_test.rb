module SMARTAppLaunch
  class WellKnownEndpointTest < Inferno::Test
    title 'FHIR server makes SMART configuration available from well-known endpoint'
    id :well_known_endpoint
    description %(
      The authorization endpoints accepted by a FHIR resource server can
      be exposed as a Well-Known Uniform Resource Identifier
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
      get(well_known_configuration_url,
          name: :smart_well_known_configuration,
          headers: { 'Accept' => 'application/json' })
      assert_response_status(200)

      assert_valid_json(request.response_body)

      config = JSON.parse(request.response_body)
      output well_known_configuration: request.response_body,
             well_known_authorization_url: config['authorization_endpoint'],
             well_known_introspection_url: config['introspection_endpoint'],
             well_known_management_url: config['management_endpoint'],
             well_known_registration_url: config['registration_endpoint'],
             well_known_revocation_url: config['revocation_endpoint'],
             well_known_token_url: config['token_endpoint']

      content_type = request.response_header('Content-Type')&.value

      assert content_type.present?, 'No `Content-Type` header received.'
      assert content_type.start_with?('application/json'),
             "`Content-Type` must be `application/json`, but received: `#{content_type}`"
    end
  end
end
