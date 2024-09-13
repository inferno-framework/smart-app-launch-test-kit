module SMARTAppLaunch
  class OpenIDFHIRUserClaimTestSTU22 < Inferno::Test
    id :smart_openid_fhir_user_claim_stu2_2
    title 'FHIR resource representing the current user can be retrieved'
    description %(
      Verify that the `fhirUser` claim is present in the ID token and that the
      FHIR resource it refers to can be retrieved. The `fhirUser` claim must be
      the url for a Patient, Practitioner, RelatedPerson, or Person resource.

      For requests from a client's registered origin(s), CORS configuration permits access to FHIR REST API endpoints.
      This test verifies that the FHIR resource is returned with the appropriate CORS header in the response.
    )

    input :id_token_payload_json, :requested_scopes, :url
    input :smart_credentials, type: :oauth_credentials
    output :id_token_fhir_user

    fhir_client do
      url :url
      oauth_credentials :smart_credentials
      headers 'Origin' => Inferno::Application['base_url']
    end

    run do
      skip_if id_token_payload_json.blank?
      skip_if !requested_scopes&.include?('fhirUser'), '`fhirUser` scope not requested'

      assert_valid_json(id_token_payload_json)
      payload = JSON.parse(id_token_payload_json)
      fhir_user = payload['fhirUser']

      valid_fhir_user_resource_types = ['Patient', 'Practitioner', 'RelatedPerson', 'Person']

      assert fhir_user.present?, 'ID token does not contain `fhirUser` claim'

      fhir_user_segments = fhir_user.split('/')
      fhir_user_resource_type = fhir_user_segments[-2]
      fhir_user_id = fhir_user_segments.last

      assert valid_fhir_user_resource_types.include?(fhir_user_resource_type),
             "ID token `fhirUser` claim does not refer to a valid resource type: #{fhir_user}"

      output id_token_fhir_user: fhir_user

      fhir_read(fhir_user_resource_type, fhir_user_id)

      assert_response_status(200)
      assert_resource_type(fhir_user_resource_type)

      inferno_origin = Inferno::Application['base_url']
      cors_allow_origin = request.response_header('Access-Control-Allow-Origin')&.value
      assert cors_allow_origin.present?, 'No `Access-Control-Allow-Origin` header received.'
      assert cors_allow_origin == inferno_origin,
             "`Access-Control-Allow-Origin` must be `#{inferno_origin}`, but received: `#{cors_allow_origin}`"
    end
  end
end
