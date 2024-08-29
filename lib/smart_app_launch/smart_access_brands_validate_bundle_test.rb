module SMARTAppLaunch
  class SMARTAccessBrandsValidateBundle < Inferno::Test
    id :smart_access_brands_valid_bundle
    title 'Server returns valid Bundle resource according to the User Access Brands Bundle Profile'
    description %(
        Verify that the returned Bundle is a valid User Access Brands Bundle according to the
        [User Access Brand Bundle Profile](https://build.fhir.org/ig/HL7/smart-app-launch/StructureDefinition-user-access-brands-bundle.html).

        This test also ensures the Bundle is the 'collection' type and that it is not empty.
      )

    run do
      load_tagged_requests('smart_access_brands_bundle')
      skip_if requests.length != 1, 'No SMART Access Brands request was made in the previous test.'
      bundle_response = requests.first.response_body

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
