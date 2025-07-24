module SMARTAppLaunch
  class FhirServerBrandBundlesAttestationTest < Inferno::Test
    title 'Complies with requirements for supporting discovery of User Access Brand Bundles'
    id :fhir_server_brand_bundles
    description %(
      The server complies with requirements for supporting discovery of User Access Brand Bundles:
      - Populates `user_access_brand_identifier` in SMART configuration JSON response if the `user_access_brand_bundle`
        refers to a Bundle with multiple Brands when populating `user_access_brand_bundle`
      - Includes a `value` when populating `user_access_brand_identifier`
      - Ensures this identifier matches exactly one `Organization.identifier` in the referenced Brand Bundle when
        populating `user_access_brand_identifier`
      - Includes a `system` in the `user_access_brand_identifier`
      - Includes exactly one Brand in the Brand Bundle with an Organization.identifier that matches the primary Brand
        identifier from the SMART configuration JSON
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@409',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@410',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@412',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@430', # same as 410
                          'hl7.fhir.uv.smart-app-launch_2.2.0@431', # is this a SHOULD requirement?
                          'hl7.fhir.uv.smart-app-launch_2.2.0@432'

    input :fhir_server_brand_bundles_correct,
          title: 'Complies with requirements for supporting discovery of User Access Brand Bundles',
          description: %(
            I attest that the server complies with requirements for supporting discovery of User Access Brand Bundles:
            - Populates `user_access_brand_identifier` in SMART configuration JSON response if the
              `user_access_brand_bundle` refers to a Bundle with multiple Brands when populating
              `user_access_brand_bundle`
            - Includes a `value` when populating `user_access_brand_identifier`
            - Ensures this identifier matches exactly one `Organization.identifier` in the referenced Brand Bundle when
              populating `user_access_brand_identifier`
            - Includes a `system` in the `user_access_brand_identifier`
            - Includes exactly one Brand in the Brand Bundle with an Organization.identifier that matches the primary
              Brand identifier from the SMART configuration JSON
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
    input :fhir_server_brand_bundles_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert fhir_server_brand_bundles_correct == 'true',
             'Server does not comply with requirements for supporting discovery of User Access Brand Bundles.'
      pass fhir_server_brand_bundles_note if fhir_server_brand_bundles_note.present?
    end
  end
end
