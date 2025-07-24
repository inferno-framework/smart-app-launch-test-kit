module SMARTAppLaunch
  class AccessTokenAttestationTest < Inferno::Test
    title 'Complies with requirements for access tokens'
    id :access_token
    description %(
      The server complies with requirements for access tokens:
      - The access token is a string of characters as defined in [RFC6749](https://tools.ietf.org/html/rfc6749)
        and [RFC6750](http://tools.ietf.org/html/rfc6750).
      - EHR authorization server decides what `expires_in` value to assign to an access token, along with the access
        token
      - EHR authorization server decides whether to issue a refresh token, along with the access token
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@85',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@88',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@89'

    input :access_token_correct,
          title: 'Complies with requirements for access tokens',
          description: %(
            I attest that the server complies with requirements for access tokens:
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
    input :access_token_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert access_token_correct == 'true',
             'Server does not comply with requirements for access tokens.'
      pass access_token_note if access_token_note.present?
    end
  end
end