module SMARTAppLaunch
  class BrandBundlesAttestationTest < Inferno::Test
    title 'Selects linked FHIR resources if they differ from resources in a Brand Bundle'
    id :brand_bundles
    description %(
      Client applications select FHIR resources linked from the `.well-known/smart-configuration` if they differ from
      the resources in a vendor-consolidated Brand Bundle when:
      - It leverages a User Access Brand Bundle
      - Requires fine-grained organizational management
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@415',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@416'

    input :brand_bundle_resources,
          title: 'Selects linked FHIR resources if they differ from resources in a Brand Bundle',
          description: %(
            I attest that the client application selects FHIR resources linked from the
            `.well-known/smart-configuration` if they differ from the resources in a vendor-consolidated
            Brand Bundle when:
            - It leverages a User Access Brand Bundle
            - Requires fine-grained organizational management
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
    input :brand_bundle_resources_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert brand_bundle_resources == 'true',
             'Client application did not select FHIR resources linked from the `.well-known/smart-configuration` when
             they differed from the resources in a vendor-consolidated Brand Bundle.'
      pass brand_bundle_resources_note if brand_bundle_resources_note.present?
    end
  end
end