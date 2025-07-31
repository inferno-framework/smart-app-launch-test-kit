module SMARTAppLaunch
  class ServerBrandBundlesAttestationTest < Inferno::Test
    title 'Complies with requirements for Brand Bundles'
    id :server_brand_bundles
    description %(
      The server complies with requirements for Brand Bundles:
      - Publishes at least a "primary brand" that references each FHIR endpoint in the Brand Bundle
      - Populates `Bundle.timestamp` to advertise the timestamp of the last change to the contents
      - Supports Cross-Origin Resource Sharing (CORS) for all GET requests to the artifacts described
      - Allows Health Data Providers to manage all data elements marked "Must-Support" in the User Access Brand and
        User Access Endpoint profiles
      - Supports customer-supplied Organization identifiers (`system` and `value`)
      - Does not use Data Absent Reasons other than `asked-declined` or `asked-unknown` in a Brand Bundle
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@396',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@398',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@400',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@402',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@403',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@405', # this is the same as 421
                          'hl7.fhir.uv.smart-app-launch_2.2.0@417', # this is the same as 396 ?
                          'hl7.fhir.uv.smart-app-launch_2.2.0@418', # is this a good spot for this? Seems similar/the same as 398
                          'hl7.fhir.uv.smart-app-launch_2.2.0@421',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@423', # this is thee same as 400
                          'hl7.fhir.uv.smart-app-launch_2.2.0@436' # same as 402 ?

    input :server_brand_bundles_correct,
          title: 'Complies with requirements for Brand Bundles',
          description: %(
            I attest that the server complies with requirements for Brand Bundles:
            - Publishes at least a "primary brand" that references each FHIR endpoint in the Brand Bundle
            - Populates `Bundle.timestamp` to advertise the timestamp of the last change to the contents
            - Supports Cross-Origin Resource Sharing (CORS) for all GET requests to the artifacts described
            - Allows Health Data Providers to manage all data elements marked "Must-Support" in the User Access Brand
              and User Access Endpoint profiles
            - Supports customer-supplied Organization identifiers (`system` and `value`)
            - Does not use Data Absent Reasons other than `asked-declined` or `asked-unknown` in a Brand Bundle
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
    input :server_brand_bundles_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert server_brand_bundles_correct == 'true',
             'Server does not comply with requirements for Brand Bundles.'
      pass server_brand_bundles_note if server_brand_bundles_note.present?
    end
  end
end
