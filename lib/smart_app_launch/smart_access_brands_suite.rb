require_relative 'smart_access_brands_group'

module SMARTAppLaunch
  class SMARTAccessBrandsSuite < Inferno::TestSuite
    id 'smart_access_brands'
    title 'SMART Access Brands STU2.2'
    version VERSION

    description <<~DESCRIPTION
      The SMART User-access Brands Test Suite verifies that Brand Bundle Publishers publish valid User-access
      Brand Bundles according to the SMART App Launch IG
      [User-access Brands and Endpoints](https://build.fhir.org/ig/HL7/smart-app-launch/brands.html#user-access-brands-and-endpoints)
      requirements.

      The specification defines FHIR profiles for Endpoint, Organization, and Bundle resources that help users connect
      their apps to health data providers. It outlines the process for data providers to publish FHIR Endpoint and
      Organization resources, where each Organization includes essential branding information such as the organization's
      name, logo, and user access details. Apps present branded Organizations to help users select the right data
      providers.

      This Test Suite provides validation testing to ensure the published User-access Brands Bundles are valid and
      contain valid resources.
    DESCRIPTION

    VALIDATION_MESSAGE_FILTERS = [
      /\A\S+: \S+: URL value '.*' does not resolve/,
      %r{\A\S+: \S+: Bundled or contained reference not found within the bundle/resource} # Validator issue with Brand profile: https://chat.fhir.org/#narrow/stream/291844-FHIR-Validator/topic/SMART.20v2.2E2.20User.20Access.20Brands.3A.20Brand.20validation.20error.3F/near/466321024
    ].freeze

    fhir_resource_validator do
      igs 'hl7.fhir.uv.smart-app-launch#2.2.0'

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
