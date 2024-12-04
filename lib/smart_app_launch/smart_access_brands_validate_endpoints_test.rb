module SMARTAppLaunch
  class SMARTAccessBrandsValidateEndpoints < Inferno::Test
    id :smart_access_brands_valid_endpoints
    title 'SMART Access Brands Bundle contains valid User Access Endpoints'
    description %(
      Verify that Bundle of User Access Brands and Endpoints contains Endpoints that are valid
      Endpoint resources according to the [User Access Endpoint Profile](https://hl7.org/fhir/smart-app-launch/STU2.2/StructureDefinition-user-access-endpoint.html).

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

    def skip_message
      %(
        No User Access Brands request was made in the previous test, and no User Access Brands Bundle was provided as
        input instead. Either provide a User Access Brands Publication URL to retrieve the Bundle via a HTTP GET
        request, or provide the Bundle as an input.
      )
    end

    input :user_access_brands_bundle,
          optional: true

    run do
      bundle_resource = scratch[:bundle_resource]

      skip_if bundle_resource.blank?, 'No SMART Access Brands Bundle contained in the response'
      skip_if bundle_resource.entry.empty?, 'The given Bundle does not contain any resources'

      endpoint_resources =
        bundle_resource
          .entry
          .map(&:resource)
          .select { |resource| resource.resourceType == 'Endpoint' }

      endpoint_resources.each do |endpoint|
        assert_valid_resource(resource: endpoint,
                              profile_url: 'http://hl7.org/fhir/smart-app-launch/StructureDefinition/user-access-endpoint')
        endpoint_id = endpoint.id
        endpoint_referenced_orgs = find_referenced_org(bundle_resource, endpoint_id)
        assert !endpoint_referenced_orgs.empty?,
               "Endpoint with id: #{endpoint_id} does not have any associated Organizations in the Bundle."
      end
    end
  end
end
