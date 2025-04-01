## Overview

The SMART App Launch STU 2.2 Client Test Suite verifies the conformance of
client systems to the STU 2.2.0 version of the HL7® FHIR®
[SMART App Launch IG](https://hl7.org/fhir/smart-app-launch/STU2.2/).

## Scope

The SMART App Launch Client Test Suite verifies that systems correctly implement
the [SMART App Launch IG](http://hl7.org/fhir/smart-app-launch/STU2.2/)
for authorizating and/or authenticating with a server in order to gain 
access to HL7® FHIR® APIs. At this time, the suite only contains tests for
the [Backend Services](https://hl7.org/fhir/smart-app-launch/STU2.2/backend-services.html)
flow.

These tests are a **DRAFT** intended to allow implementers to perform
preliminary checks of their systems against SMART requirements and 
[provide feedback](https://github.com/inferno-framework/smart-app-launch-test-kit/issues)
on the tests. Future versions of these tests may verify other
requirements and may change the test verification logic.

## Test Methodology

For these tests Inferno simulates a SMART server that supports the backend services
flow. Testers will
1. Provide registration details as inputs, including a JSON Web Key Set (JWKS)
   an optionally a client id if a specific one should be used.
2. Request an access token using the registered JWKS and client id.
3. Use that access token on a FHIR API request.

The simulated server is relatively permissive in the sense that it will often
provide successful responses even when the request is not conformant. When
requesting tokens, Inferno will return an access token as long as it can find
the client id and the signature is valid. This allows incomplete systems to
run the tests. However, these non-conformant requests will be flagged by
the tests as failures so that systems will not pass the tests without being
fully conformant.

## Running the Tests

### Quick Start

The following inputs must be provided by the tester at a minimum to execute
any tests in this suite:
1. **SMART JSON Web Key Set (JWKS)**: The SMART client's public JSON Web Key Set including
   key(s) that Inferno will use to verify the signature on incoming token requests. May
   be provided as either a publicly accessible url containing the JWKS, or the raw JWKS.

Additional inputs described in the *Additional Inputs* section below can enable
verification of additional content types and some Subscription creation error scenarios.

### Demonstration

To try out these tests without a SMART client implementation, these tests can be exercised
using the SMART App Launch server test suite and a simple HTTP request generator. The following
steps use [Postman](https://www.postman.com/) to generate the access request using 
[this collection](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/docs/demo/FHIR%20Request.postman_collection.json). Install the app and import the collection before following these
steps.

1. Start an instance of the SMART App Launch STU2.2 Client test suite.
2. From the drop down in the upper left, select preset "Demo: Run Against the SMART Server Suite".
3. Click the "RUN ALL TESTS" button in the upper right and click "SUBMIT"
4. In a new tab, start an instance of the SMART App Launch STU2.2 Test Suite
5. From the drop down in the upper left, select preset "Demo: Run Against the SMART Server Suite"
6. Select test group **3** Backend Services from the left panel, click the "RUN TESTS" button
   in the upper right, and click "SUBMIT"
7. Find the access token to use for the data access request by opening test **3.2.05** Authorization
   request succeeds when supplied correct information, click on the "REQUESTS" tab, clicking on the "DETAILS"
   button, and expanding the "Response Body". Copy the "access_token" value, which will be a ~100 character
   string of letters and numbers (e.g., eyJjbGllbnRfaWQiOiJzbWFydF9jbGllbnRfdGVzdF9kZW1vIiwiZXhwaXJhdGlvbiI6MTc0MzUxNDk4Mywibm9uY2UiOiJlZDI5MWIwNmZhMTE4OTc4In0)
8. Open Postman and open the "FHIR Request" Collection. Click the "Variables" tab and add the copied access token
   as the current value of the "bearer_token" variable. Save the collection.
9. Select the "Patient Read" request and click "Send". A FHIR Patient resource should be returned.
10. Return to the client tests and click the link to continue and complete the tests.

The client tests should pass with the exception of test **1.2.02** Verify SMART Token Requests. This is
expected as the Server tests make several intentionally invalid token requests. Inferno's simulated SMART
server responds successfully to those requests when the client id can be identified, but flags them as
not conformant causing these expected failures. Because responding with an access token to non-conformant
token requests is itself not conformant, there are corresponding failures on the server test in tests **3.2.02**,
**3.2.04**, and **3.2.04**. There may be other SMART server test failures due to an assumption that
servers support the app launch capabilities in addition to backend services.

### Additional Input Details

Two additional inputs are available to support testers 
- **Client Id**: Testers may specify a client id for Inferno to use for the test session if they
  have one already configured.
- **FHIR Response to Echo**: The focus of this test kit is on the auth protocol, so the
  simulated FHIR server implemented in this test suite is very simple and will by default
  return a FHIR OperationOutcome to any request made. Testers may provide a static
  FHIR JSON body for Inferno to return instead. In this case, the simulation is a simple
  echo and Inferno does not check that the response if appropriate for the request made.

## Current Limitations

This test kit is still in draft form and does not test all of the requirements and features
described in the SMART App Launch IG for clients. Notably, only the backend services flow
is tested at this time.

The following sections list other known gaps and limitations.

### SMART Server Simulation Limitations

This test suite contains a simulation of a SMART Backend Services server which is not fully
general and not all conformant clients may be able to interact with it. However, the intention
is not to prevent systems from passing for making conformant choices that Inferno's simulation
does not support. One specific example is that the SMART configuration metadata available at
`.well-known/smart-configuration` for the simulated server is fixed and cannot be changed by
testers at this time. Please report any issues that prevent conformant systems from passing in
the [github repository's issues page](https://github.com/inferno-framework/smart-app-launch-test-kit/issues/).

### FHIR Server Simulation Limitations

The FHIR server simulation used to support clients in demonstrating their ability to access
FHIR APIs using access tokens obtained using the SMART flows is very limited. Testers are currently
able to provide a single static response that will be echoed for any FHIR request made. While
Inferno will never implement a fully general FHIR server simulation, additional options may be added
in the future based on community feedback.