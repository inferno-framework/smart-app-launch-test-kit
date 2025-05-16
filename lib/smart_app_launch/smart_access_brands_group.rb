require_relative 'smart_access_brands_validation_group'
require_relative 'smart_access_brands_retrieval_group'

module SMARTAppLaunch
  class SMARTAccessBrandsGroup < Inferno::TestGroup
    id :retrieve_and_validate_smart_access_brands
    title 'Retrieve and Validate SMART Access Brands Bundle'
    description %(
      Verify that the Brand Bundle Publisher makes its User-access Brands publication publicly available
      in the format defined by the [User Access Brand Bundle Profile](https://hl7.org/fhir/smart-app-launch/STU2.2/StructureDefinition-user-access-brands-bundle.html)
      with valid Endpoint and Organization entries according to the
      [User Access Endpoint Profile](https://hl7.org/fhir/smart-app-launch/STU2.2/StructureDefinition-user-access-endpoint.html)
      and the [User Access Brand Profile](https://hl7.org/fhir/smart-app-launch/STU2.2/StructureDefinition-user-access-brand.html)
      respectively. This test group will issue a HTTP GET request against the supplied URL to retrieve the publisher's
      User-access Brands list and ensure the list is publicly accessible. It will then ensure that the returned
      User-access Brands list publication is in the User Access Brand Bundle Profile format with valid User Access
      Brands and User Access Endpoints.

      For systems that provide the User Access Brands Bundle at a public endpoint, please run
      this test with the User Access Brands Publication URL input populated and the User Access Brands Bundle
      input left blank. While it is the expectation of the specification for the User Access Brands Bundle to be served
      at a public-facing endpoint, testers can validate a User Access Brands Bundle not served at a public endpoint by
      running these tests with the User Access Brands Bundle input populated and the User Access Brands Publication URL
      input left blank. This will cause these group of retrieval group of tests to skip, rather than pass completely,
      as being served at an stable location is considered a requirement of the spec.
    )

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

      While it is the expectation of the specification for the User Access Brands Bundle to be publicly available,
      for systems that do not have a User Access Brand Bundle served at a public endpoint, testers can validate by
      providing the User Access Brand Bundle as an input and leaving the User Access Brand Publication URL input blank.
    INSTRUCTIONS

    run_as_group

    input :user_access_brands_publication_url,
          title: 'User Access Brands Publication URL',
          description: %(The URL to the developer's public User Access Brands Publication. Insert your User Access
          Brands publication URL if you host your Bundle at a public-facing endpoint and want Inferno to retrieve the
          Bundle from there.),
          optional: true

    input :user_access_brands_bundle,
          title: 'User Access Brands Bundle',
          description: %(The developer's User Access Brands Publication in the JSON string format. If this input is
          populated, Inferno will use the Bundle inserted here to do validation. Insert your User Access Brands
          Bundle in the JSON format in this input to validate your list without Inferno needing to access the Bundle
          via a public-facing endpoint.),
          type: 'textarea',
          optional: true

    group from: :smart_access_brands_retrieval
    group from: :smart_access_brands_validation
  end
end
