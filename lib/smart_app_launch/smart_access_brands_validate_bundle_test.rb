module SMARTAppLaunch
  class SMARTAccessBrandsValidateBundle < Inferno::Test
    id :smart_access_brands_valid_bundle
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@396',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@398',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@417'
    title 'Server returns valid Bundle resource according to the User Access Brands Bundle Profile'
    description %(
        Verify that the returned Bundle is a valid User Access Brands Bundle according to the
        [User Access Brand Bundle Profile](https://hl7.org/fhir/smart-app-launch/STU2.2/StructureDefinition-user-access-brands-bundle.html).

        This test also ensures the Bundle is the 'collection' type and that it is not empty.
      )

    input :user_access_brands_bundle,
          optional: true

    def skip_message
      %(
        No User Access Brands request was made in the previous test, and no User Access Brands Bundle was provided as
        input instead. Either provide a User Access Brands Publication URL to retrieve the Bundle via a HTTP GET
        request, or provide the Bundle as an input.
      )
    end

    run do
      bundle_response = if user_access_brands_bundle.blank?
                          load_tagged_requests('smart_access_brands_bundle')
                          skip skip_message if requests.length != 1
                          requests.first.response_body
                        else
                          user_access_brands_bundle
                        end

      skip_if bundle_response.blank?, 'No SMART Access Brands Bundle contained in the response'

      assert_valid_json(bundle_response)
      bundle_resource = FHIR.from_contents(bundle_response)
      assert_resource_type(:bundle, resource: bundle_resource)
      assert_valid_resource(resource: bundle_resource, profile_url: 'http://hl7.org/fhir/smart-app-launch/StructureDefinition/user-access-brands-bundle')

      assert(bundle_resource.type == 'collection', 'The SMART Access Brands Bundle must be type `collection`')
      assert(bundle_resource.timestamp.present?,
             'Bundle.timestamp must be populated to advertise the timestamp of the last change to the contents')
      assert !bundle_resource.entry.empty?, 'The given Bundle does not contain any brands or endpoints.'
    end
  end
end
