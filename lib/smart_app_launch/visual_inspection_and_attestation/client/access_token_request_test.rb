module SMARTAppLaunch
  class AccessTokenRequestAttestationTest < Inferno::Test
    title 'Complies with requirements for issuing access token requests'
    id :access_token_request
    description %(
      The client application complies with requirements for issuing requests for access tokens by:
      - Issuing an HTTP POST to the EHR authorization server's token endpoint URL using content-type
        `application/x-www-form-urlencoded`
      - Omitting the `client_id` parameter for `confidential apps`
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@62',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@72'

    input :access_token_request_correct,
          title: 'Complies with requirements for issuing access token requests',
          description: %(
            I attest that the client application complies with requirements for issuing requests for access tokens by:
            - Issuing an HTTP POST to the EHR authorization server's token endpoint URL using content-type
              `application/x-www-form-urlencoded`
            - Omitting the `client_id` parameter for `confidential apps`
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
    input :access_token_request_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert access_token_request_correct == 'true',
             'Client application does not comply with requirements for issuing access token requests.'
      pass access_token_request_note if access_token_request_note.present?
    end
  end
end
