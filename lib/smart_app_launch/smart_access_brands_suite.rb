require_relative 'smart_access_brands_group'

module SMARTAppLaunch
  class SMARTAccessBrandsSuite < Inferno::TestSuite
    id 'smart_access_brands'
    title 'SMART User-access Brands and Endpoints STU2.2'
    short_title 'SMART User-access Brands'
    version VERSION

    description <<~DESCRIPTION
      The SMART User-access Brands Test Suite verifies that Brand Bundle Publishers publish valid User-access
      Brand Bundles according to the SMART App Launch IG
      [User-access Brands and Endpoints](https://hl7.org/fhir/smart-app-launch/STU2.2/brands.html#user-access-brands-and-endpoints)
      requirements.

      The specification defines FHIR profiles for Endpoint, Organization, and Bundle resources that help users connect
      their apps to health data providers. It outlines the process for data providers to publish FHIR Endpoint and
      Organization resources, where each Organization includes essential branding information such as the organization's
      name, logo, and user access details. Apps present branded Organizations to help users select the right data
      providers.

      This test suite is currently designed to fetch and validate a single User-Access Brand Bundle. It does not
      currently evaluate the system's ability to allow Health Data Providers to manage all data elements marked
      "Must-Support" in the "User Access Brand" and "User Access Endpoint" profiles.
    DESCRIPTION

    input_instructions <<~INSTRUCTIONS
      For systems that make their User Access Brand Bundle available at a public endpoint, please input
      the User Access Brand Publication URL to retrieve the Bundle from there in order to perform validation, and leave
      the User Access Brand Bundle input blank.

      Although it is expected that systems do have their Bundle publicly available, for systems that do not have a
      User Access Brand Bundle served at a public endpoint, testers can validate by providing the User Access Brand
      Bundle as an input and leaving the User Access Brand Publication URL input blank.
    INSTRUCTIONS

    VALIDATION_MESSAGE_FILTERS = [
      /\A\S+: \S+: URL value '.*' does not resolve/,
      %r{\A\S+: \S+: Bundled or contained reference not found within the bundle/resource} # Validator issue with Brand profile: https://chat.fhir.org/#narrow/stream/291844-FHIR-Validator/topic/SMART.20v2.2E2.20User.20Access.20Brands.3A.20Brand.20validation.20error.3F/near/466321024
    ].freeze

    fhir_resource_validator do
      igs 'hl7.fhir.uv.smart-app-launch#2.2.0'

      cli_context({
                    # Allow example URLs because we give tester option to follow URLs anyhow
                    # (configurable) and its nice to be able to have the examples in the IG pass
                    allowExampleUrls: true
                  })

      message_filters = VALIDATION_MESSAGE_FILTERS

      $num_messages = 0
      $capped_message = false
      $num_errors = 0
      $capped_errors = false

      exclude_message do |message|
        matches_filter = message_filters.any? { |filter| filter.match? message.message }

        unless matches_filter
          if message.type == 'error'
            $num_errors += 1
          else
            $num_messages += 1
          end
        end

        matches_filter ||
          (message.type != 'error' && $num_messages > 50 && !message.message.include?('Inferno is only showing the first')) ||
          (message.type == 'error' && $num_errors > 20 && !message.message.include?('Inferno is only showing the first'))
      end

      perform_additional_validation do
        if $num_messages > 50 && !$capped_message
          $capped_message = true
          { type: 'info', message: 'Inferno is only showing the first 50 validation info and warning messages.' }
        elsif $num_errors > 20 && !$capped_errors
          $capped_errors = true
          { type: 'error', message: 'Inferno is only showing the first 20 validation error messages.' }
        end
      end
    end

    Dir.each_child(File.join(__dir__, '/smart_access_brands_examples/')) do |filename|
      resource_example = File.read(File.join(__dir__, '/smart_access_brands_examples/', filename))
      if filename.end_with?('.erb')
        erb_template = ERB.new(resource_example)
        resource_example = JSON.parse(erb_template.result).to_json
        filename = filename.delete_suffix('.erb')
        headers = { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*',
                    'Etag' => SecureRandom.hex(32) }
      else
        filename = "#{filename.delete_suffix('.json')}/metadata"
        headers = { 'Content-Type' => 'application/json' }
      end
      route_handler = proc { [200, headers, [resource_example]] }

      route :get, File.join('/examples/', filename), route_handler
    end

    group from: :retrieve_and_validate_smart_access_brands
  end
end
