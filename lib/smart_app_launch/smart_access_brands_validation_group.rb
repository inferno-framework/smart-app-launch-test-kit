require_relative 'smart_access_brands_validate_bundle_test'
require_relative 'smart_access_brands_validate_endpoints_test'
require_relative 'smart_access_brands_validate_endpoint_urls_test'
require_relative 'smart_access_brands_validate_brands_test'

module SMARTAppLaunch
  class SMARTAccessBrandsValidationGroup < Inferno::TestGroup
    id :smart_access_brands_validation
    title 'Validate SMART Access Brands Bundle'
    description %(
      These tests ensure that the publisher's User Access Brands publication is in
      a valid Bundle according to the [User Access Brand Bundle Profile](https://build.fhir.org/ig/HL7/smart-app-launch/StructureDefinition-user-access-brands-bundle.html).
      It ensures that this User Access Brand Bundle has its brand and endpoint
      details contained in valid Endpoints according to the [User Access Endpoint Profile](https://build.fhir.org/ig/HL7/smart-app-launch/StructureDefinition-user-access-endpoint.html)
      and valid Brands (Organizations) according to the [User Access Brand Profile](https://build.fhir.org/ig/HL7/smart-app-launch/StructureDefinition-user-access-brand.html).
    )
    run_as_group

    test from: :smart_access_brands_valid_bundle
    test from: :smart_access_brands_valid_endpoints
    test from: :smart_access_brands_valid_endpoint_urls
    test from: :smart_access_brands_valid_brands
  end
end
