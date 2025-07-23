module SMARTAppLaunch
  class AccessTokenAttestationTest < Inferno::Test
    title 'Adheres to guidelines for access tokens'
    id :access_token
    description %(
      Servers adhere to the following guidelines for access tokens:
      - The access token is a string of characters as defined in [RFC6749](https://tools.ietf.org/html/rfc6749)
        and [RFC6750](http://tools.ietf.org/html/rfc6750).
      - EHR authorization server decides what `expires_in` value to assign to an access token, along with the access
        token
      - EHR authorization server decides whether to issue a refresh token, along with the access token
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@85',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@88',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@89'

    input :access_token_guidelines,
          title: 'Adheres to guidelines for access tokens',
          description: %(
            I attest that the server adheres to the following guidelines for access tokens:
            - The access token is a string of characters as defined in [RFC6749](https://tools.ietf.org/html/rfc6749)
              and [RFC6750](http://tools.ietf.org/html/rfc6750).
            - EHR authorization server decides what `expires_in` value to assign to an access token, along with the
              access token
            - EHR authorization server decides whether to issue a refresh token, along with the access token
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
    input :access_token_guidelines_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert access_token_guidelines == 'true',
             'Server did not follow guidelines for access tokens.'
      pass access_token_guidelines_note if access_token_guidelines_note.present?
    end
  end
end