module SMARTAppLaunch
  class FhirAuthorizationServerAttestationTest < Inferno::Test
    title 'Authenticates and links FHIR authorization server with TLS'
    id :fhir_auth_server_auth_tls
    description %(
      The client application authenticates the identify of the FHIR authorization server and establishes a secure link
      for exchange with TLS.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@230'

    input :fhir_auth_server_auth_tls_correct,
          title: 'Authenticates and links FHIR authorization server with TLS',
          description: %(
            I attest that the client application authenticates the identify of the FHIR authorization server and establishes a secure link
            for exchange with TLS.
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
    input :fhir_auth_server_auth_tls_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert fhir_auth_server_auth_tls_correct == 'true',
             'Client application did not authenticate and links FHIR authorization server
             with TLS.'
      pass fhir_auth_server_auth_tls_note if fhir_auth_server_auth_tls_note.present?
    end
  end
end
