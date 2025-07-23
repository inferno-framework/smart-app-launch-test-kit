module SMARTAppLaunch
  class JSONResponseAttestationTest < Inferno::Test
    title 'Uses the `application/json` type for JSON documents'
    id :json_response
    description %(
      Servers return JSON documents using the `application/json` mime type.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@380'

    input :json_document,
          title: 'Uses the `application/json` type for JSON documents',
          description: %(
            I attest that the server returns JSON documents using the `application/json` mime type.
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
    input :json_document_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert json_document == 'true',
             'Server did not use the `application/json` type for JSON documents.'
      pass json_document_note if json_document_note.present?
    end
  end
end