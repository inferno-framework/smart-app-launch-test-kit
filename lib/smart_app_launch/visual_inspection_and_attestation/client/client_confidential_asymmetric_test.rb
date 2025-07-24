module SMARTAppLaunch
  class ClientConfidentialAsymmetricAttestationTest < Inferno::Test
    title 'Properly supports SMART\'s `client-confidential-asymmetric` capability'
    id :client_confidential_asymmetric
    description %(
      The client application complies with the requirements for supporting SMART's `client-confidential-asymmetric`
      capability:
      - Registers with a FHIR server by following steps in [`client-confidential-asymmetric` authentication](https://hl7.org/fhir/smart-app-launch/STU2.2/client-confidential-asymmetric.html#registering-a-client-communicating-public-keys)
      - Uses the [Transport Layer Security (TLS) Protocol Version 1.2 (RFC5246)](https://tools.ietf.org/html/rfc5246) to
        authenticate the identity of the FHIR authorization server and to establish a link for exchanges between the
        client and the FHIR authorization server’s token endpoint
      - Generates a one-time-use JWT that is used to authenticate to the FHIR authorization server
      - Signs the JWT with the client's private key
      - Requires the `alg` value when generating the one-time-use JWT
      - Requires the `kid` value when generating the one-time-use JWT
      - Matches the `jku` header value with the JWKS URL value that was supplied to the FHIR authorization server at
        registration
      - Generates the one-time-use JWT with the `exp` value set to no more than five minutes in the future
      - Possesses a client_secret when registered for Client Password authentication
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@225',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@318',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@319',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@320',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@321',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@322',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@325',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@331',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@345'

    input :client_confidential_asymmetric_correct,
          title: 'Properly supports SMART\'s `client-confidential-asymmetric` capability',
          description: %(
            I attest that the client application complies with the requirements for supporting SMART's
            `client-confidential-asymmetric` capability:
            - Registers with a FHIR server by following steps in [`client-confidential-asymmetric` authentication](https://hl7.org/fhir/smart-app-launch/STU2.2/client-confidential-asymmetric.html#registering-a-client-communicating-public-keys)
            - Uses the [Transport Layer Security (TLS) Protocol Version 1.2 (RFC5246)](https://tools.ietf.org/html/rfc5246)
              to authenticate the identity of the FHIR authorization server and to establish a link for exchanges
              between the client and the FHIR authorization server’s token endpoint
            - Generates a one-time-use JWT that is used to authenticate to the FHIR authorization server
            - Signs the JWT with the client's private key
            - Requires the `alg` value when generating the one-time-use JWT
            - Requires the `kid` value when generating the one-time-use JWT
            - Matches the `jku` header value with the JWKS URL value that was supplied to the FHIR authorization server
              at registration
            - Generates the one-time-use JWT with the `exp` value set to no more than five minutes in the future
            - Possesses a client_secret when registered for Client Password authentication
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
    input :client_confidential_asymmetric_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert client_confidential_asymmetric_correct == 'true',
             'Client application does not comply with the requirements for supporting SMART\'s `client-confidential-asymmetric` capability.'
      pass client_confidential_asymmetric_note if client_confidential_asymmetric_note.present?
    end
  end
end
