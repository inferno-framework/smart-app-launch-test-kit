module SMARTAppLaunch
  class BearerTokenCookiesAttestationTest < Inferno::Test
    title 'Does not store bearer tokens in cookies'
    id :bearer_token_cookies
    description %(
      The client application does not store bearer tokens in cookies.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@7'

    input :bearer_token_cookies_correct,
          title: 'Does not store bearer tokens in cookies',
          description: %(
            I attest that the client application does not store bearer tokens in cookies.
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
    input :bearer_token_cookies_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert bearer_token_cookies_correct == 'true',
             'Client application stores bearer tokens in cookies.'
      pass bearer_token_cookies_note if bearer_token_cookies_note.present?
    end
  end
end
