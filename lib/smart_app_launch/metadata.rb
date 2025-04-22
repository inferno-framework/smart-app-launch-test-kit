require_relative 'version'

module SMARTAppLaunch
  class Metadata < Inferno::TestKit
    id :smart_app_launch_test_kit
    title 'SMART App Launch Test Kit'
    description <<~DESCRIPTION
      The SMART App Launch Test Kit validates the conformance of authorization server
      implementations and clients that interact with them to a specified version of the
      [SMART Application Launch Framework Implementation
      Guide](http://hl7.org/fhir/smart-app-launch/index.html).  This Test Kit also
      provides Brand Bundle Publisher testing for the User-access Brands and Endpoints
      specification.  This Test Kit supports following versions of the SMART App
      Launch IG: [STU1](https://hl7.org/fhir/smart-app-launch/1.0.0/),
      [STU2](http://hl7.org/fhir/smart-app-launch/STU2/), and
      [STU2.2](http://hl7.org/fhir/smart-app-launch/STU2.2/).
      <!-- break -->

      This Test Kit is [open
      source](https://github.com/inferno-framework/smart-app-launch-test-kit#license)
      and freely available for use or adoption by the health IT community including
      EHR vendors, health app developers, and testing labs. It is built using the
      [Inferno Framework](https://inferno-framework.github.io/inferno-core/). The
      Inferno Framework is designed for reuse and aims to make it easier to build test
      kits for any FHIR-based data exchange.

      To run tests for a SMART App Launch authorization server, select one of the
      "SMART App Launch" suites.  To run tests for a Brand Bundle Publisher, select
      the "SMART User-access Brands and Endpoints" suite.

      ## Status

      The SMART App Launch Test Kit provides five suites that verify that systems
      correctly implement different aspects and versions of the SMART App Launch IG.
      - Three server suites (SMART App Launch STU1, STU2, and STU2.2) verifying that SMART server implementations
        can provide authorization and/or authentication services to
        client applications accessing HL7 FHIR APIs. Thes
        - Standalone Launch
        - EHR Launch
        - Backend Services (STU2 and STU2.2 only)
        - Token Introspection (STU2 and STU2.2 only)
      - A client suite (SMART App Launch STU2.2 Client) verifying that a SMART STU2.2
        client can obtain and use an access token using the SMART flows.
      - A suite verifying a server's compliance with the User-access Brands and Endpoints
        specification.

      See the test descriptions within the test kit for detail on the specific
      validations performed as part of testing these requirements.

      ## Repository

      The SMART App Launch Test Kit GitHub repository can be [found
      here](https://github.com/inferno-framework/smart-app-launch-test-kit).

      ## Providing Feedback and Reporting Issues

      We welcome feedback on the tests, including but not limited to the following
      areas:

      - Validation logic, such as potential bugs, lax checks, and unexpected failures.
      - Requirements coverage, such as requirements that have been missed, tests that
        necessitate features that the IG does not require, or other issues with the
        interpretation of the IG's requirements.
      - User experience, such as confusing or missing information in the test UI.

      Please report any issues with this set of tests in the [issues
      section](https://github.com/inferno-framework/smart-app-launch-test-kit/issues)
      of the repository.
    DESCRIPTION
    suite_ids [:smart, :smart_stu2, :smart_stu2_2, :smart_access_brands, :smart_client_stu2_2]
    tags ['SMART App Launch', 'Endpoint Publication']
    last_updated LAST_UPDATED
    version VERSION
    maturity 'Medium'
    authors ['Stephen MacVicar', 'Karl Naden']
    repo 'https://github.com/inferno-framework/smart-app-launch-test-kit'
  end
end
