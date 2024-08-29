module SMARTAppLaunch
  class SMARTAccessBrandsValidateEndpoints < Inferno::Test
    id :smart_access_brands_valid_endpoints
    title 'SMART Access Brands Bundle contains valid User Access Endpoints'
    description %(
      Verify that Bundle of User Access Brands and Endpoints contains Endpoints that are valid
      Endpoint resources according to the [User Access Endpoint Profile](https://build.fhir.org/ig/HL7/smart-app-launch/StructureDefinition-user-access-endpoint.html).

      Along with validating the Endpoint resources, this test also ensures that each endpoint contains a primary brand
      by checking if it is referenced by at least 1 Organization resource.
      )

    def find_referenced_org(bundle_resource, endpoint_id)
      bundle_resource
        .entry
        .map(&:resource)
        .select { |resource| resource.resourceType == 'Organization' }
        .map(&:endpoint)
        .flatten
        .map(&:reference)
        .select { |reference| reference.include? endpoint_id }
    end

    run do
      load_tagged_requests('smart_access_brands_bundle')
      skip_if requests.length != 1, 'No SMART Access Brands request was made in the previous test.'
      bundle_response = requests.first.response_body

      skip_if bundle_response.blank?, 'No SMART Access Brands Bundle contained in the response'

      assert_valid_json(bundle_response)
      bundle_resource = FHIR.from_contents(bundle_response)

      skip_if bundle_resource.entry.empty?, 'The given Bundle does not contain any resources'

      assert_valid_bundle_entries(bundle: bundle_resource,
                                  resource_types: {
                                    Endpoint: 'http://hl7.org/fhir/smart-app-launch/StructureDefinition/user-access-endpoint'
                                  })

      endpoint_ids =
        bundle_resource
          .entry
          .map(&:resource)
          .select { |resource| resource.resourceType == 'Endpoint' }
          .map(&:id)

      endpoint_ids.each do |endpoint_id|
        endpoint_referenced_orgs = find_referenced_org(bundle_resource, endpoint_id)
        assert !endpoint_referenced_orgs.empty?,
               "Endpoint with id: #{endpoint_id} does not have any associated Organizations in the Bundle."
      end
    end
  end
end
