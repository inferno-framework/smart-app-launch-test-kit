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

    smart_access_brands_bundle = File.read(File.join(__dir__, 'smart_access_brands_example.json'))
    bundle_route_handler = proc { [200, { 'Content-Type' => 'application/json' }, [smart_access_brands_bundle]] }
    route :get, File.join('/examples/', 'smart_access_brands_example.json'), bundle_route_handler

    group from: :smart_access_brands_test_group
  end
end
