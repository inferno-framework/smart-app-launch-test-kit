module SMARTAppLaunch
  class FhirRequestAuthHeaderAttestationTest < Inferno::Test
    title 'Includes an access token as a Bearer token in Authorization header of FHIR requests'
    id :fhir_request_authorization_header
    description %(
      The Client application issues a request for fetching FHIR resources that includes an `Authorization` header that
      presents the `access_token` as a "Bearer" token.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@93',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@264'

    input :auth_header_access_token,
          title: 'Includes an access token as a Bearer token in the Authorization header of a FHIR request',
          description: %(
            I attest that the client application issues a request for fetching FHIR resources that includes an
            `Authorization` header that presents the `access_token as a "Bearer` token.
          ),
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Yes',
                value: 'true'
              },
              {
                label: 'No',
                value: 'false'
              }
            ]
          }
    input :auth_header_access_token_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert auth_header_access_token == 'true',
             'Client application did not include an `access_token` as a "Bearer" token in a FHIR resource request.'
      pass auth_header_access_token_note if auth_header_access_token_note.present?
    end
  end
end