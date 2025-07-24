module SMARTAppLaunch
  class HTTPPostGetAttestationTest < Inferno::Test
    title 'Uses HTTP GET and POST methods with appropriate request serialization'
    id :http_post_get
    description %(
      The client application uses the HTTP GET or HTTP POST method and serializes the HTTP GET
      method requests using URI Query String Serialization and the HTTP POST method requests using Form
      Serialization and application/x-www-form-urlencoded content type.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@51',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@52'

    input :http_post_get_correct,
          title: 'Uses the HTTP GET or HTTP POST method and serializes the requests appropriately',
          description: %(
            I attest that the client application uses the HTTP GET or HTTP POST method and serializes the HTTP GET
            method requests using URI Query String Serialization and the HTTP POST method requests using Form
            Serialization and application/x-www-form-urlencoded content type.
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
    input :http_post_get_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert http_post_get == 'true',
             'Client application does not use HTTP GET or HTTP POST methods with appropriate request serialization.'
      pass http_post_get_note if http_post_get_note.present?
    end
  end
end
