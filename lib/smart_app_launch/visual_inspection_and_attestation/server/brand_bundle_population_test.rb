module SMARTAppLaunch
  class BrandBundlePopulationAttestationTest < Inferno::Test
    title 'Populates the brand bundle with the required attributes'
    id :brand_bundle_population
    description %(
      Server populates the brand bundle with the required attributes:
      - Populates `Bundle.timestamp` to advertise the timestamp of the last change to the contents
      - Populates `Bundle.entry.resource.meta.lastUpdated` with a more detailed timestamp if the system tracks
        updates per Resource
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@418',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@419'

    input :brand_bundle_attributes,
          title: 'Populates the brand bundle with the required attributes',
          description: %(
            I attest that the server populates the brand bundle with the required attributes:
            - Populates `Bundle.timestamp` to advertise the timestamp of the last change to the contents
            - Populates `Bundle.entry.resource.meta.lastUpdated` with a more detailed timestamp if the system tracks
              updates per Resource
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
    input :brand_bundle_attributes_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert brand_bundle_attributes == 'true',
             'Server did not populate the brand bundle with the required attributes.'
      pass brand_bundle_attributes_note if brand_bundle_attributes_note.present?
    end
  end
end