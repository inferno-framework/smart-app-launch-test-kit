module SMARTAppLaunch
  class FhirRequestAuthHeaderAttestationTest < Inferno::Test
    title 'Includes an access token as a Bearer token in Authorization header of FHIR requests'
    id :fhir_request_authorization_header
    description %(
      The client application issues a request for fetching FHIR resources that includes an `Authorization` header that
      presents the `access_token` as a "Bearer" token.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@93',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@264'

    input :fhir_request_authorization_header_correct,
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
    input :fhir_request_authorization_header_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert fhir_request_authorization_header_correct == 'true',
             'Client application does not include an `access_token` as a "Bearer" token in a FHIR resource request.'
      pass fhir_request_authorization_header_note if fhir_request_authorization_header_note.present?
    end
  end
end
