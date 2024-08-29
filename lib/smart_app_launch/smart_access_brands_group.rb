require_relative 'smart_access_brands_validation_group'
require_relative 'smart_access_brands_retrieval_group'

module SMARTAppLaunch
  class SMARTAccessBrandsGroup < Inferno::TestGroup
    id :smart_access_brands_test_group
    title 'Retrieve and Validate SMART Access Brands Bundle'
    description %(
      Verify that the Brand Bundle Publisher makes its User-access Brands publication publicly available
      in the format defined by the [User Access Brand Bundle Profile](https://build.fhir.org/ig/HL7/smart-app-launch/StructureDefinition-user-access-brands-bundle.html)
      with valid Endpoint and Organization entries according to the
      [User Access Endpoint Profile](https://build.fhir.org/ig/HL7/smart-app-launch/StructureDefinition-user-access-endpoint.html)
      and the [User Access Brand Profile](https://build.fhir.org/ig/HL7/smart-app-launch/StructureDefinition-user-access-brand.html)
      respectively. This test group will issue a HTTP GET request against the supplied URL to retrieve the publisher's
      User-access Brands list and ensure the list is publicly accessible. It will then ensure that the returned
      User-access Brands list publication is in the User Access Brand Bundle Profile format with valid User Access
      Brands and User Access Endpoints.
    )

    group from: :smart_access_brands_retrieval_group
    group from: :smart_access_brands_validation_group
  end
end
