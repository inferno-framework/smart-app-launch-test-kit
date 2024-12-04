module SMARTAppLaunch
  class SMARTAccessBrandsValidateEndpointURLs < Inferno::Test
    id :smart_access_brands_valid_endpoint_urls
    title 'All Endpoint resource referenced URLS should be valid and available'
    description %(
      Verify that User Access Brands Bundle contains Endpoints that contain URLs that are both valid
      and available.
    )

    input :user_access_brands_bundle,
          optional: true

    input :endpoint_availability_limit,
          title: 'Endpoint Availability Limit',
          description: %(
      Input a number to cap the number of Endpoints that Inferno will send requests to check for availability.
      This can help speed up validation when there are large number of endpoints in the Service Base URL Bundle.
    ),
          optional: true

    input :endpoint_availability_success_rate,
          title: 'Endpoint Availability Success Rate',
          description: %(
      Select an option to choose how many Endpoints have to be available and send back a valid capability
      statement for the Endpoint validation test to pass.
    ),
          type: 'radio',
          options: {
            list_options: [
              {
                label: 'All',
                value: 'all'
              },
              {
                label: 'At Least 1',
                value: 'at_least_1'
              },
              {
                label: 'None',
                value: 'none'
              }
            ]
          },
          default: 'all'

    def get_endpoint_availability_limit(endpoint_availability_limit)
      return if endpoint_availability_limit.blank?

      endpoint_availability_limit.to_i
    end

    def skip_message
      %(
        No User Access Brands request was made in the previous test, and no User Access Brands Bundle was provided as
        input instead. Either provide a User Access Brands Publication URL to retrieve the Bundle via a HTTP GET
        request, or provide the Bundle as an input.
      )
    end

    run do
      bundle_resource = scratch[:bundle_resource]

      skip_if bundle_resource.blank?, 'No SMART Access Brands Bundle contained in the response'
      skip_if bundle_resource.entry.empty?, 'The given Bundle does not contain any resources'

      endpoint_list = bundle_resource
        .entry
        .map(&:resource)
        .select { |resource| resource.resourceType == 'Endpoint' }
        .map(&:address)
        .uniq

      check_limit = get_endpoint_availability_limit(endpoint_availability_limit)
      one_endpoint_valid = false

      endpoint_list.each_with_index do |address, index|
        assert_valid_http_uri(address)

        next if endpoint_availability_success_rate == 'none' || (check_limit.present? && index >= check_limit)

        address = address.delete_suffix('/')
        get("#{address}/metadata", client: nil, headers: { Accept: 'application/fhir+json' })

        if endpoint_availability_success_rate == 'all'
          assert_response_status(200)
          assert resource.present?, 'The content received does not appear to be a valid FHIR resource'
          assert_resource_type(:capability_statement)
        else
          warning do
            assert_response_status(200)
            assert resource.present?, 'The content received does not appear to be a valid FHIR resource'
            assert_resource_type(:capability_statement)
          end

          if !one_endpoint_valid && response[:status] == 200 && resource.present? &&
             resource.resourceType == 'CapabilityStatement'
            one_endpoint_valid = true
          end
        end
      end

      if endpoint_availability_success_rate == 'at_least_1'
        assert(one_endpoint_valid, %(
            There were no Endpoints that were available and returned a valid Capability Statement in the Service Base
            URL Bundle'
          ))
      end
    end
  end
end
