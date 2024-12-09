module SMARTAppLaunch
  class SMARTAccessBrandsValidateBrands < Inferno::Test
    id :smart_access_brands_valid_brands
    title 'Service Base URL List contains valid Brand resources'
    description %(
      Verify that Bundle of User Access Brands and Endpoints contains Brands that are valid
      Organization resources according to the [User Access Brand Profile](https://hl7.org/fhir/smart-app-launch/STU2.2/StructureDefinition-user-access-brand.html).

      Along with validating the Organization resources, this test also ensures:
        - Each endpoint referenced in the Organization portal extension also appear in Organization.endpoint
        - Any endpoints referenced by the Organization must appear in the Bundle

      This test does not currently validate availability or format of Brand or Portal logos.
    )

    def regex_match?(resource_id, reference)
      return false if resource_id.blank?

      %r{#{resource_id}(?:/[^\/]*|\|[^\/]*)*/?$}.match?(reference)
    end

    def find_referenced_endpoint(bundle_resource, endpoint_id_ref)
      bundle_resource
        .entry
        .map(&:resource)
        .select { |resource| resource.resourceType == 'Endpoint' }
        .map(&:id)
        .select { |endpoint_id| regex_match?(endpoint_id, endpoint_id_ref) }
    end

    def find_parent_organization(bundle_resource, org_reference)
      bundle_resource
        .entry
        .map(&:resource)
        .select { |resource| resource.resourceType == 'Organization' }
        .find { |parent_org| regex_match?(parent_org.id, org_reference) }
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
        next if portal_endpoint_found

        add_message('error', %(
          Portal endpoints must also appear at Organization.endpoint. The portal endpoint with reference
          #{portal_endpoint.valueReference.reference} was not found at Organization.endpoint.
        ))
      end
    end

    def skip_message
      %(
        No User Access Brands request was made in the previous test, and no User Access Brands Bundle was provided as
        input instead. Either provide a User Access Brands Publication URL to retrieve the Bundle via a HTTP GET
        request, or provide the Bundle as an input.
      )
    end

    def scratch_bundle_resource
      scratch[:bundle_resource] ||= {}
    end

    run do
      bundle_resource = scratch_bundle_resource

      skip_if bundle_resource.blank?, %(
        No successful User Access Brands request was made in the previous test, or no User Access Brands Bundle was
        provided
      )
      skip_if bundle_resource.entry.empty?, 'The given Bundle does not contain any resources'

      organization_resources = bundle_resource
        .entry
        .map(&:resource)
        .select { |resource| resource.resourceType == 'Organization' }

      organization_resources.each do |organization|
        resource_is_valid?(resource: organization)

        endpoint_references = organization.endpoint.map(&:reference)
        if organization.extension.present?
          portal_extension = find_extension(organization.extension, '/organization-portal')
          if portal_extension.present?
            portal_endpoints = find_all_extensions(portal_extension.extension, 'portalEndpoint')
            check_portal_endpoints(portal_endpoints, endpoint_references)
          end
        end

        if organization.endpoint.empty?
          if organization.partOf.blank?
            add_message('error', %(
              Organization with id: #{organization.id} does not have the endpoint or partOf field populated
            ))
            next
          end

          parent_organization = find_parent_organization(bundle_resource, organization.partOf.reference)

          if parent_organization.blank?
            add_message('error', %(
              Organization with id: #{organization.id} references parent Organization not found in the Bundle:
              #{organization.partOf.reference}
            ))
            next
          end

          if parent_organization.endpoint.empty?
            add_message('error', %(
              Organization with id: #{organization.id} has parent Organization with id: #{parent_organization.id} that
              does not have the `endpoint` field populated.
            ))
          end
        else
          endpoint_references.each do |endpoint_id_ref|
            organization_referenced_endpts = find_referenced_endpoint(bundle_resource, endpoint_id_ref)
            next unless organization_referenced_endpts.empty?

            add_message('error', %(
              Organization with id: #{organization.id} references an Endpoint endpoint_id_ref that is not contained in
              this bundle.
            ))
          end
        end
      end

      error_messages = messages.select { |msg| msg[:type] == 'error' }
      non_error_messages = messages.reject { |msg| msg[:type] == 'error' }

      @messages = []
      @messages += error_messages.first(20) unless error_messages.empty?
      @messages += non_error_messages.first(50) unless non_error_messages.empty?

      if error_messages.count > 20 || non_error_messages.count > 50
        info_message = 'Inferno is only showing the first 20 error and 50 warning/information validation messages'
        add_message('info', info_message)
      end

      assert messages.empty? || messages.none? { |msg| msg[:type] == 'error' }, %(
        Some Organizations in the Service Base URL Bundle are invalid
      )
    end
  end
end
