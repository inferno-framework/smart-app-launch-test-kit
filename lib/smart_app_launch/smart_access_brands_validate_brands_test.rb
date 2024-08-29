module SMARTAppLaunch
  class SMARTAccessBrandsValidateBrands < Inferno::Test
    id :smart_access_brands_valid_brands
    title 'Service Base URL List contains valid Brand resources'
    description %(
      Verify that Bundle of User Access Brands and Endpoints contains Brands that are valid
      Organization resources according to the [User Access Brand Profile](https://build.fhir.org/ig/HL7/smart-app-launch/StructureDefinition-user-access-brand.html).

      Along with validating the Organization resources, this test also ensures:
        - Each endpoint referenced in the Organization portal extension also appear in Organization.endpoint
        - Any endpoints referenced by the Organization must appear in the Bundle
    )

    def find_referenced_endpoint(bundle_resource, endpoint_id_ref)
      bundle_resource
        .entry
        .map(&:resource)
        .select { |resource| resource.resourceType == 'Endpoint' }
        .map(&:id)
        .select { |endpoint_id| endpoint_id_ref.include? endpoint_id }
    end

    def find_extension(extension_array, extension_name)
      extension_array.find do |extension|
        extension.url.ends_with?(extension_name)
      end
    end

    def find_all_extensions(extension_array, extension_name)
      extension_array.select do |extension|
        extension.url == extension_name
      end
    end

    def check_portal_endpoints(portal_endpoints, organization_endpoints)
      portal_endpoints.each do |portal_endpoint|
        portal_endpoint_found = organization_endpoints.any? do |endpoint_reference|
          portal_endpoint.valueReference.reference == endpoint_reference
        end
        assert(portal_endpoint_found, %(
          Portal endpoints must also appear at Organization.endpoint. The portal endpoint with reference
          #{portal_endpoint.valueReference.reference} was not found at Organization.endpoint.))
      end
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
                                    Organization: 'http://hl7.org/fhir/smart-app-launch/StructureDefinition/user-access-brand'
                                  })

      organization_resources = bundle_resource
        .entry
        .map(&:resource)
        .select { |resource| resource.resourceType == 'Organization' }

      organization_resources.each do |organization|
        endpoint_references = organization.endpoint.map(&:reference)

        if organization.extension.present?
          portal_extension = find_extension(organization.extension, '/organization-portal')
          if portal_extension.present?
            portal_endpoints = find_all_extensions(portal_extension.extension, 'portalEndpoint')
            check_portal_endpoints(portal_endpoints, endpoint_references)
          end
        end

        endpoint_references.each do |endpoint_id_ref|
          organization_referenced_endpts = find_referenced_endpoint(bundle_resource, endpoint_id_ref)
          assert !organization_referenced_endpts.empty?,
                 "Organization with id: #{organization.id} references an Endpoint that is not contained in this
                   bundle."
        end
      end
    end
  end
end
