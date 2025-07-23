module SMARTAppLaunch
  class PublicKeysAttestationTest < Inferno::Test
    title 'Follows guidelines for public keys'
    id :public_keys
    description %(
      Client applications adhere to the following guidelines for public keys:
      - Generates or obtains an asymmetric key pair before running against a FHIR server
      - Registers its public key set with a FHIR server's authorization service
      - Protects the associated private key from unauthorized disclosure and corruption
      - Chooses a server-supported method for communicating JWKs
      - Communicates the TLS-protected endpoint where the client's public JWK Set can be found in the URL to
        JWK Set Method
      - Enables accessibility to the endpoint in the URL to JWK Set method via TLS without client authentication
        or authorization
      - Generates JSON Web Signature in accordance with [RFC7515](https://tools.ietf.org/html/rfc7515)
      - Supports RS384 for the JSON Web Application (JWA) header parameter
      - Includes JWKs where each represents an asymmetric key by including `kty` and `kid` properties
      - Includes JWKs for RSA public keys that include `n` and `e` values
      - Includes JWKs for ECDSA public keys that include `crv`, `x`, and `y` values
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@290',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@291',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@295',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@298',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@301',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@302',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@307',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@308',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@308', # requirements 308 and 309 are seemingly identical
                          'hl7.fhir.uv.smart-app-launch_2.2.0@313',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@314',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@315'

    input :public_key_guidelines,
          title: 'Follows guidelines for public keys',
          description: %(
            I attest that the client application adheres to the following guidelines for public keys:
            - Generates or obtains an asymmetric key pair before running against a FHIR server
            - Registers its public key set with a FHIR server's authorization service
            - Protects the associated private key from unauthorized disclosure and corruption
            - Chooses a server-supported method for communicating JWKs
            - Communicates the TLS-protected endpoint where the client's public JWK Set can be found in the URL to
              JWK Set Method
            - Enables accessibility to the endpoint in the URL to JWK Set method via TLS without client authentication
              or authorization
            - Generates JSON Web Signature in accordance with [RFC7515](https://tools.ietf.org/html/rfc7515)
            - Supports RS384 for the JSON Web Application (JWA) header parameter
            - Includes JWKs where each represents an asymmetric key by including `kty` and `kid` properties
            - Includes JWKs for RSA public keys that include `n` and `e` values
            - Includes JWKs for ECDSA public keys that include `crv`, `x`, and `y` values
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
    input :public_key_guidelines_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert public_key_guidelines == 'true',
             'Client application did not follow guidelines for public keys.'
      pass public_key_guidelines_note if public_key_guidelines_note.present?
    end
  end
end