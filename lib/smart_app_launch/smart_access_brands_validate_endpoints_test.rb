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

    def regex_match?(resource_id, reference)
      return false if resource_id.blank?

      %r{#{resource_id}(?:/[^\/]*|\|[^\/]*)*/?$}.match?(reference)
    end

    def find_referenced_org(bundle_resource, endpoint_id)
      bundle_resource
        .entry
        .map(&:resource)
        .select { |resource| resource.resourceType == 'Organization' }
        .map(&:endpoint)
        .flatten
        .map(&:reference)
        .select { |reference| regex_match?(endpoint_id, reference) }
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

      endpoint_resources =
        bundle_resource
          .entry
          .map(&:resource)
          .select { |resource| resource.resourceType == 'Endpoint' }

      endpoint_resources.each do |endpoint|
        resource_is_valid?(resource: endpoint)

        endpoint_id = endpoint.id
        endpoint_referenced_orgs = find_referenced_org(bundle_resource, endpoint_id)
        next unless endpoint_referenced_orgs.empty?

        add_message('error', %(
          Endpoint with id: #{endpoint_id} does not have any associated Organizations in the Bundle.
        ))
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
        Some Endpoints in the Service Base URL Bundle are invalid
      )
    end
  end
end
