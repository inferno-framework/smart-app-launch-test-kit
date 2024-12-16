module SMARTAppLaunch
  class OpenIDFHIRUserClaimTest < Inferno::Test
    id :smart_openid_fhir_user_claim
    title 'FHIR resource representing the current user can be retrieved'
    description %(
      Verify that the `fhirUser` claim is present in the ID token and that the
      FHIR resource it refers to can be retrieved. The `fhirUser` claim must be
      the url for a Patient, Practitioner, RelatedPerson, or Person resource
    )

    input :id_token_payload_json, :url
    input :smart_credentials, type: :auth_info, options: { mode: 'access' }
    input :smart_auth_info, type: :auth_info, options: { mode: 'auth' }

    output :id_token_fhir_user

    fhir_client do
      url :url
      auth_info :smart_credentials
    end

    run do
      skip_if id_token_payload_json.blank?
      skip_if !smart_auth_info.requested_scopes&.include?('fhirUser'), '`fhirUser` scope not requested'

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
    end
  end
end
