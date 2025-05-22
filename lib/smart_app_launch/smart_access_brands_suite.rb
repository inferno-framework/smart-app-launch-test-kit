require_relative 'smart_access_brands_group'

module SMARTAppLaunch
  class SMARTAccessBrandsSuite < Inferno::TestSuite
    id 'smart_access_brands'
    title 'SMART User-access Brands and Endpoints STU2.2'
    short_title 'SMART User-access Brands'

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

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@396',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@398',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@400',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@402',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@403',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@405'

    input_instructions <<~INSTRUCTIONS
      For systems that make their User Access Brand Bundle available at a public endpoint, please input
      the User Access Brand Publication URL to retrieve the Bundle from there in order to perform validation, and leave
      the User Access Brand Bundle input blank.

      Although it is expected that systems do have their Bundle publicly available, for systems that do not have a
      User Access Brand Bundle served at a public endpoint, testers can validate by providing the User Access Brand
      Bundle as an input and leaving the User Access Brand Publication URL input blank.
    INSTRUCTIONS

    source_code_url('https://github.com/inferno-framework/smart-app-launch-test-kit')
    download_url('https://github.com/inferno-framework/smart-app-launch-test-kit/releases')
    report_issue_url('https://github.com/inferno-framework/smart-app-launch-test-kit/issues')

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

      exclude_message do |message|
        message_filters.any? { |filter| filter.match? message.message }
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
