module SMARTAppLaunch
  class CORSOpenIDFHIRUserClaimTest < Inferno::Test
    id :smart_cors_openid_fhir_user_claim
    title 'SMART FHIR User REST API Endpoint Enables Cross-Origin Resource Sharing (CORS)'
    description %(
      The SMART [Considerations for Cross-Origin Resource Sharing (CORS) support](http://hl7.org/fhir/smart-app-launch/STU2.2/app-launch.html#considerations-for-cross-origin-resource-sharing-cors-support)
      specifies that servers that support purely browser-based apps SHALL enable Cross-Origin Resource Sharing (CORS)
      as follows:

        - For requests from a client's registered origin(s), CORS configuration permits access to the token
          endpoint and to FHIR REST API endpoints.

      This test verifies that a request to the FHIR REST API endpoint for the FHIR user is returned with the appropriate
      CORS header.
    )
    optional

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@17'

    input :url, :id_token_fhir_user
    input :smart_credentials, type: :oauth_credentials

    fhir_client do
      url :url
      oauth_credentials :smart_credentials
      headers 'Origin' => Inferno::Application['inferno_host']
    end

    run do
      valid_fhir_user_resource_types = ['Patient', 'Practitioner', 'RelatedPerson', 'Person']

      fhir_user_segments = id_token_fhir_user.split('/')
      fhir_user_resource_type = fhir_user_segments[-2]
      fhir_user_id = fhir_user_segments.last

      assert valid_fhir_user_resource_types.include?(fhir_user_resource_type),
             "ID token `fhirUser` claim does not refer to a valid resource type: #{id_token_fhir_user}"

      fhir_read(fhir_user_resource_type, fhir_user_id)

      assert_response_status(200)

      inferno_origin = Inferno::Application['inferno_host']
      cors_allow_origin = request.response_header('Access-Control-Allow-Origin')&.value
      assert cors_allow_origin.present?, 'No `Access-Control-Allow-Origin` header received.'
      assert cors_allow_origin == inferno_origin || cors_allow_origin == '*',
             "`Access-Control-Allow-Origin` must be `#{inferno_origin}`, but received: `#{cors_allow_origin}`"
    end
  end
end
