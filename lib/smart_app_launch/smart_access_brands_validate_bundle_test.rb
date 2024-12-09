module SMARTAppLaunch
  class SMARTAccessBrandsValidateBundle < Inferno::Test
    id :smart_access_brands_valid_bundle
    title 'Server returns valid Bundle resource according to the User Access Brands Bundle Profile'
    description %(
        Verify that the returned Bundle is a valid User Access Brands Bundle according to the
        [User Access Brand Bundle Profile](https://hl7.org/fhir/smart-app-launch/STU2.2/StructureDefinition-user-access-brands-bundle.html).

        This test also ensures the Bundle is the 'collection' type and that it is not empty.
      )

    input :resource_validation_limit,
          title: 'Limit Validation to a Maximum Resource Count',
          description: %(
        Input a number to limit the number of Bundle entries that are validated. For very large bundles, it is
        recommended to limit the number of Bundle entries to avoid long test run times.
        To validate all, leave blank.
      ),
          optional: true

    input :user_access_brands_bundle,
          optional: true

    def skip_message
      %(
        No User Access Brands request was made in the previous test, and no User Access Brands Bundle was provided as
        input instead. Either provide a User Access Brands Publication URL to retrieve the Bundle via a HTTP GET
        request, or provide the Bundle as an input.
      )
    end

    def get_resource_entries(bundle_resource, resource_type)
      bundle_resource
        .entry
        .select { |entry| entry.resource.resourceType == resource_type }
        .uniq
    end

    def limit_bundle_entries(resource_validation_limit, bundle_resource)
      new_entries = []

      organization_entries = get_resource_entries(bundle_resource, 'Organization')
      endpoint_entries = get_resource_entries(bundle_resource, 'Endpoint')

      organization_entries.each do |organization_entry|
        break if resource_validation_limit <= 0

        new_entries.append(organization_entry)
        resource_validation_limit -= 1

        found_endpoint_entries = []
        organization_resource = organization_entry.resource

        if organization_resource.endpoint.present?
          found_endpoint_entries = find_referenced_endpoints(organization_resource.endpoint, endpoint_entries)
        elsif organization_resource.partOf.present?
          parent_org = find_parent_organization_entry(organization_entries, organization_resource.partOf.reference)

          unless parent_org.blank? || resource_already_exists?(new_entries, parent_org, 'Organization')
            new_entries.append(parent_org)
            resource_validation_limit -= 1

            parent_org_resource = parent_org.resource
            found_endpoint_entries = find_referenced_endpoints(parent_org_resource.endpoint, endpoint_entries)
          end
        end

        found_endpoint_entries.each do |found_endpoint_entry|
          next if resource_already_exists?(new_entries, found_endpoint_entry, 'Endpoint')

          new_entries.append(found_endpoint_entry)

          endpoint_entries.delete_if do |entry|
            entry.resource.resourceType == 'Endpoint' && entry.resource.id == found_endpoint_entry.resource.id
          end

          resource_validation_limit -= 1
        end
      end

      endpoint_entries.each do |endpoint_entry|
        break if resource_validation_limit <= 0

        new_entries.append(endpoint_entry)
        resource_validation_limit -= 1
      end

      new_entries
    end

    def regex_match?(resource_id, reference)
      return false if resource_id.blank?

      %r{#{resource_id}(?:/[^\/]*|\|[^\/]*)*/?$}.match?(reference)
    end

    def find_parent_organization_entry(organization_entries, org_reference)
      organization_entries
        .find { |parent_org_entry| regex_match?(parent_org_entry.resource.id, org_reference) }
    end

    def find_referenced_endpoints(organization_endpoints, endpoint_entries)
      endpoints = []
      organization_endpoints.each do |endpoint_ref|
        found_endpoint = endpoint_entries.find do |endpoint_entry|
          regex_match?(endpoint_entry.resource.id, endpoint_ref.reference)
        end
        endpoints.append(found_endpoint) if found_endpoint.present?
      end
      endpoints
    end

    def resource_already_exists?(new_entries, found_resource_entry, resource_type)
      new_entries.any? do |entry|
        entry.resource.resourceType == resource_type && (entry.resource.id == found_resource_entry.resource.id)
      end
    end

    run do
      bundle_response = if user_access_brands_bundle.blank?
                          load_tagged_requests('smart_access_brands_bundle')
                          skip skip_message if requests.length != 1
                          requests.first.response_body
                        else
                          user_access_brands_bundle
                        end

      skip_if bundle_response.blank?, %(
        No successful User Access Brands request was made in the previous test, or no User Access Brands Bundle was
        provided
      )

      assert_valid_json(bundle_response)
      bundle_resource = FHIR.from_contents(bundle_response)
      assert_resource_type(:bundle, resource: bundle_resource)

      if resource_validation_limit.present?
        limited_entries = limit_bundle_entries(resource_validation_limit.to_i,
                                               bundle_resource)
        bundle_resource.entry = limited_entries
      end

      scratch[:bundle_resource] = bundle_resource

      assert(bundle_resource.type.present?, 'The SMART Access Brands Bundle is missing the required `type` field')
      assert(bundle_resource.type == 'collection', 'The SMART Access Brands Bundle must be type `collection`')
      assert(bundle_resource.timestamp.present?,
             'Bundle.timestamp must be populated to advertise the timestamp of the last change to the contents')
      assert !bundle_resource.entry.empty?, 'The given Bundle does not contain any brands or endpoints.'
      assert(bundle_resource.total.blank?, 'The `total` field is not allowed in `collection` type Bundles')

      entry_full_urls = []

      bundle_resource.entry.each_with_index do |entry, index|
        entry_num = index + 1
        assert(entry.resource.present?, %(
          Bundle entry #{entry_num} missing the `resource` field. For Bundles of type collection, all entries must
          contain resources.
        ))

        assert(entry.request.blank?, %(
          Bundle entry #{entry_num} contains the `request` field. For Bundles of type collection, all entries must not
          have request or response elements
        ))
        assert(entry.response.blank?, %(
          Bundle entry #{entry_num} contains the `response` field. For Bundles of type collection, all entries must not
          have request or response elements
        ))
        assert(entry.search.blank?, %(
          Bundle entry #{entry_num} contains the `search` field. Entry.search is allowed only for `search` type Bundles.
        ))

        assert(entry.fullUrl.exclude?('/_history/'), %(
          Bundle entry #{entry_num} contains a version specific reference in the `fullUrl` field
        ))

        full_url_exists = entry_full_urls.any? do |hash|
          hash['fullUrl'] == entry.fullUrl && hash['versionId'] == entry.resource&.meta&.versionId
        end

        assert(!full_url_exists, %(
          The SMART Access Brands Bundle contains entries with duplicate fullUrls (#{entry.fullUrl}) and versionIds
          (#{entry.resource&.meta&.versionId}). FullUrl must be unique in a bundle, or else entries with the same
          fullUrl must have different meta.versionId
        ))

        entry_full_urls.append({ 'fullUrl' => entry.fullUrl, 'versionId' => entry.resource&.meta&.versionId })
      end
    end
  end
end
