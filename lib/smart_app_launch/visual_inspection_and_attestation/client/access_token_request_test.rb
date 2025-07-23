module SMARTAppLaunch
  class AccessTokenRequestAttestationTest < Inferno::Test
    title 'Complies with requirements for issuing access token requests'
    id :access_token_request
    description %(
      Client applications comply with requirements for issuing requests for access tokens by:
      - Issuing an HTTP POST to the EHR authorization server's token endpoint URL using content-type
        `application/x-www-form-urlencoded`
      - Omitting the `client_id` parameter for `confidential apps`
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@62',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@72'

    input :http_post_content_type,
          title: 'Uses correct content-type in HTTP POST to the EHR authorization server\'s token endpoint URL',
          description: %(
            I attest that the client application issues an HTTP POST to the EHR authorization server's token
            endpoint URL using content-type `application/x-www-form-urlencoded`.
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
    input :http_post_content_type_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    input :client_id_omit,
          title: 'Omits the `client_id` parameter for `confidential apps`',
          description: %(
            I attest that the client application omits the `client_id` parameter in access token requests for
            `confidential apps.`
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
    input :client_id_omit_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert http_post_content_type == 'true',
             'Client application did not use `content-type` `application/x-www-form-urlencoded` in HTTP POST to
             the EHR authorization server\'s token endpoint URL.'
      pass http_post_content_type_note if http_post_content_type_note.present?

      assert client_id_omit == 'true',
             'Client application did not omit `client_id` in access token requests for `confidential apps`.'
      pass client_id_omit_note if client_id_omit_note.present?
    end
  end
end
