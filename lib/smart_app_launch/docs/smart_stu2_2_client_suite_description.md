## Overview

The SMART App Launch STU 2.2 Client Test Suite verifies the conformance of
client systems to the STU 2.2.0 version of the HL7® FHIR®
[SMART App Launch IG](https://hl7.org/fhir/smart-app-launch/STU2.2/).

## Scope

The SMART App Launch Client Test Suite verifies that systems correctly implement
the aproach specified in the [SMART App Launch IG](http://hl7.org/fhir/smart-app-launch/STU2.2/)
for authorizing and potentially authenticating with a server in order to gain 
access to HL7® FHIR® APIs. The suite contains options for test clints following
- the [App Launch flow](https://hl7.org/fhir/smart-app-launch/STU2.2/app-launch.html), for
  - Public clients not authenticating with the server.
  - Confidential clients using [symmetric authentication](https://hl7.org/fhir/smart-app-launch/STU2.2/client-confidential-symmetric.html).
  - Confidential clients using [asymmetric authentication](https://hl7.org/fhir/smart-app-launch/STU2.2/client-confidential-asymmetric.html).
- the [Backend Services flow](https://hl7.org/fhir/smart-app-launch/STU2.2/backend-services.html),
  which requires clients to use [asymmetric authentication](https://hl7.org/fhir/smart-app-launch/STU2.2/client-confidential-asymmetric.html).

These tests are a **DRAFT** intended to allow implementers to perform
preliminary checks of their systems against SMART requirements and 
[provide feedback](https://github.com/inferno-framework/smart-app-launch-test-kit/issues)
on the tests. Future versions of these tests may verify other
requirements and may change the test verification logic.

## Test Methodology

For these tests Inferno simulates a SMART server. Testers will
1. Choose which type of client to test during test session initialization.
1. Provide registration details specific to the chosen client type as inputs,
   including authentication details and optionally a client id if a specific
   one should be used.
2. Follow the appropriate SMART flow to request an access token using the
   registered client id.
3. Use that access token on a FHIR API request.

The simulated server is relatively permissive in the sense that it will often
provide successful responses even when the request is not conformant. When
requesting authorization codes and access tokens, Inferno will provide one as
long as it can find the client id and verify authentication. This allows incomplete
systems to run the tests. However, these non-conformant requests will be flagged by
the tests as failures so that systems will not pass the tests without being
fully conformant.

## Running the Tests

### Quick Start

Depending on which type of client was selected, the following inputs must be provided
at a minimum by the tester to execute any tests in this suite:
- **SMART App Launch Redirect URI(s)** (required for all *SMART App Launch* clients):
  A comma-separated list of one or more URIs that the app will sepcify as the target
  of the redirect for Inferno to use when providing the authorization code.
- **SMART Confidential Symmetric Client Secret** (required for the *SMART App Launch Confidential
  Symmetric* clients only)): The client secret that the confidential symmetric client will send with
  token requests to authenticate the client to Inferno.
- **SMART JSON Web Key Set (JWKS)** (required for *Confidential Asymmetric* clients): The SMART
  client's public JSON Web Key Set including key(s) that Inferno will use to verify the signature
  on incoming token requests. May be provided as either a publicly accessible url containing the
  JWKS, or the raw JWKS.

The *Additional Inputs* section below describes options available to customize
the behavior of Inferno's server simulation.

### Demonstration

To try out these tests without a SMART client implementation, these tests can be demonstrated
using the SMART App Launch server test suite.

#### App Launch Demonstration

1. Start an instance of the SMART App Launch STU2.2 Client test suite and choose
   *SMART App Launch* options as the SMART Client Type: Public, Confidential Symmetric,
   or Confidential Asymmetric. Remember the choice for later use.
1. From the drop down in the upper left, select preset "Demo: Run Against the SMART Server Suite".
1. Click the "RUN ALL TESTS" button in the upper right and click "SUBMIT".
1. In a new tab, start an instance of the SMART App Launch STU2.2 Test Suite.
1. From the drop down in the upper left, select the "Demo: Run Against the SMART Client Suite
   ([security type])" preset corresponding to the client type choice made in step 1.
1. Select test group **1** Standalone Launch from the left panel, click the "RUN TESTS" button
   in the upper right, and click "SUBMIT". When prompted, click the link to authorize and
   the tests will run to completion.
1. Select test group **2** EHR Launch from the left panel, click the "RUN TESTS" button
   in the upper right, and click "SUBMIT".
1. When prompted to launch the app, return to the Client tests and open the `launch` link
   in a new tab which will open a new copy of the server tests.
1. When prompted in the new tab, click the link to authorize and the tests will run to completion.
1. Select test group **4** Token Introspection from the left panel, click the "RUN ALL TESTS" button
   in the upper right, and click "SUBMIT". When prompted, click the link to authorize and
   the tests will run to completion.
1. Return to the client tests and click the link to continue and complete the tests.

The client tests should pass. The server tests are expected to have errors in the Token Introspection
tests for the invalid token tests because Inferno is not able to associate the invalid token introspection
test with the client session.

#### Backend Services Demonstration

The Backend Services server tests do not make a data access request, so a simple HTTP request
generator in needed to demonstrate the Backend Services client tests. The following
steps use [Postman](https://www.postman.com/) to generate the access request using 
[this collection](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/docs/demo/FHIR%20Request.postman_collection.json). Install the app and import the collection before following these
steps.

1. Start an instance of the SMART App Launch STU2.2 Client test suite and choose
   *SMART Backend Services Confidential Asymmetric Client* as the SMART Client Type.
2. From the drop down in the upper left, select preset "Demo: Run Against the SMART Server Suite".
3. Click the "RUN ALL TESTS" button in the upper right and click "SUBMIT".
4. In a new tab, start an instance of the SMART App Launch STU2.2 Test Suite.
5. From the drop down in the upper left, select preset "Demo: Run Against the SMART Client Suite (Confidential Asymmetric)".
6. Select test group **3** Backend Services from the left panel, click the "RUN TESTS" button
   in the upper right, and click "SUBMIT".
7. Find the access token to use for the data access request by opening test **3.2.05** Authorization
   request succeeds when supplied correct information, click on the "REQUESTS" tab, clicking on the "DETAILS"
   button, and expanding the "Response Body". Copy the "access_token" value, which will be a ~100 character
   string of letters and numbers (e.g., eyJjbGllbnRfaWQiOiJzbWFydF9jbGllbnRfdGVzdF9kZW1vIiwiZXhwaXJhdGlvbiI6MTc0MzUxNDk4Mywibm9uY2UiOiJlZDI5MWIwNmZhMTE4OTc4In0).
8. Open Postman and open the "FHIR Request" Collection. Click the "Variables" tab and add the copied access token
   as the current value of the `bearer_token` variable. Also update the
   `base_url` value for where the test is running (see details on the "Overview" tab).
   Save the collection.
9. Select the "Patient Read" request and click "Send". A FHIR Patient resource should be returned.
10. Return to the client tests and click the link to continue and complete the tests.

The client tests should pass with the exception of test **1.2.02** Verify SMART Token Requests. This is
expected as the Server tests make several intentionally invalid token requests. Inferno's simulated SMART
server responds successfully to those requests when the client id can be identified, but flags them as
not conformant causing these expected failures. Because responding with an access token to non-conformant
token requests is itself not conformant there are corresponding failures on the server test in tests **3.2.02**,
**3.2.03**, and **3.2.04**.

### Additional Inputs

#### Additional Registration Inputs

Testers have the option to provide two additional SMART registration details:
- **Client Id**: Testers may specify a client id for Inferno to use for the test session if they
  have one already configured.
- **SMART App Launch URL(s)** (available for all *SMART App Launch* clients): To demonstrate an EHR
  launch, provide one or more URLs, separated by commas, that Inferno can use to launch the app.

#### Inputs Controlling Token Responses

Inferno's SMART simulation is shallow and does not include the details needed to populate
the token response [context data](https://hl7.org/fhir/smart-app-launch/STU2.2/scopes-and-launch-context.html)
when requested by apps using scopes during the *SMART App Launch* flow. If the tested app
needs and will request these details, the tester must provide them using the following inputs:
- **Launch Context** (available for all *SMART App Launch* clients): Testers can provide a JSON
  array for Inferno to use as the base for building a token response on. This can include
  keys like `"patient"` when the `launch/patient` scope will be requested. Note that when keys that Inferno
  also populates (e.g. `access_token` or `id_token`) are included, the Inferno value will be returned.
- **FHIR User Relative Reference** (available for all *SMART App Launch* clients): Testers
  can provide a FHIR relative reference (`<resource type>/<id>`) for the FHIR user record
  to return with the `id_token` when the `openid` and `fhirUser` scopes are requested. If populated,
  include the corresponding resource in the **Available Resources** input (See the "Inputs
  Controlling FHIR Responses" section) so that it can be accessed via FHIR read.

#### Inputs Controlling FHIR Responses
The focus of this test kit is on the auth protocol, so the simulated FHIR server implemented
in this test suite is very simple. It will respond to any FHIR request with either:
  - A resource from a tester-provided Bundle in the **Available Resources* input
    if the request is a read matching a resource type and id found in the Bundle.
  - Otherwise, the contents of the **Default FHIR Response** input, if provided.
  - Otherwise, an OperationOutcome indicating no response was available.

The two inputs that control these response include:
- **Available Resources**: A FHIR Bundle of resources to make available via the
  simulated FHIR sever. Each entry must contain a resource with the id element
  populated. Each instance present will be available for retrieval from Inferno
  at the endpoint: `<fhir-base>/<resource type>/<instance id>`. These will only
  be available through the read interaction.
- **FHIR Response to Echo**: A static FHIR JSON body for Inferno to return for all FHIR requests
  not covered by reads of instances in the **Available Resources** input. In this case,
  the simulation is a simple echo and Inferno does not check that the response is
  appropriate for the request made.

## Current Limitations

This test kit is still in draft form and does not test all of the requirements and features
described in the SMART App Launch IG for clients.

The following sections list other known gaps and limitations.

### SMART Server Simulation Limitations

This test suite contains a simulation of a SMART server which is not fully
general and not all conformant clients may be able to interact with it. However, the intention
is not to prevent systems from passing for making conformant choices that Inferno's simulation
does not support. One specific example is that the SMART configuration metadata available at
`.well-known/smart-configuration` for the simulated server is fixed and cannot be changed by
testers at this time. Please report any issues that prevent conformant systems from passing in
the [github repository's issues page](https://github.com/inferno-framework/smart-app-launch-test-kit/issues/).

### FHIR Server Simulation Limitations

The FHIR server simulation used to support clients in demonstrating their ability to access
FHIR APIs using access tokens obtained using the SMART flows is very limited. Testers are currently
able to provide a list of resources to be read and a single static response that will be echoed for any
other FHIR request made. While Inferno will never implement a fully general FHIR server simulation,
additional options, such as may be added in the future based on community feedback.