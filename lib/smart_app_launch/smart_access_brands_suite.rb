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

    fhir_resource_validator do
      igs 'hl7.fhir.uv.smart-app-launch#2.2.0'

      exclude_message do |message|
        message.message.match?(/\A\S+: \S+: URL value '.*' does not resolve/)
      end
    end

    Dir.each_child(File.join(__dir__, '/smart_access_brands_examples/')) do |filename|
      resource_example = File.read(File.join(__dir__, '/smart_access_brands_examples/', filename))
      if filename.end_with?('.erb')
        erb_template = ERB.new(resource_example)
        resource_example = JSON.parse(erb_template.result).to_json
        filename = "#{filename.delete_suffix('.erb')}.json"
        headers = { 'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*',
                    'Etag' => SecureRandom.hex(32) }
      else
        filename = "#{filename.delete_suffix('.json')}/metadata"
        headers = { 'Content-Type' => 'application/json' }
      end
      route_handler = proc { [200, headers, [resource_example]] }

      route :get, File.join('/examples/', filename), route_handler
    end

    group from: :smart_access_brands_test_group
  end
end
