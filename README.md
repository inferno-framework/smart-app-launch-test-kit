# Inferno SMART App Launch Test Kit

This is a collection of tests for the [SMART Application Launch Framework
Implementation Guide](http://hl7.org/fhir/smart-app-launch/index.html) using the
[Inferno Framework](https://inferno-framework.github.io/inferno-core/), verifying
that a server can provide authorization and/or authentication services to client 
applications accessing HL7® FHIR® APIs.

## Instructions

- Clone this repo.
- Run `setup.sh` in this repo.
- Run `run.sh` in this repo.
- Navigate to `http://localhost`. The SMART test suite will be available.

## Versions
This test kit contains both the SMART App Launch STU1 and SMART App Launch STU2
suites. While these suites are generally designed to test implementations of
the SMART App Launch Framework, each suite is tailored to the
[STU1](https://hl7.org/fhir/smart-app-launch/1.0.0/) and
[STU2](http://hl7.org/fhir/smart-app-launch/STU2/) versions of SMART, respectively.

## Importing tests

Tests from this test kit can be imported to perform the SMART App Launch
workflow as part of another test suite. The tests are arranged in groups which
can be easily reused.

In order for the redirect and launch urls to be determined correctly, make sure
that the `INFERNO_HOST` environment variable is populated in `.env` with the
scheme and host where inferno will be hosted.

### Example

```ruby
require 'smart_app_launch_test_kit'

class MySuite < Inferno::TestSuite
  input :url

  group do
    title 'Auth'

    group from: :smart_discovery
    group from: :smart_standalone_launch
    group from: :smart_openid_connect
  end

  group do
    title 'Make some HL7® FHIR® requests using SMART credentials'

    input :smart_credentials

    fhir_client do
      url :url
      oauth_credentials :smart_credentials # Obtained from the auth group
    end

    test do
      title 'Retrieve patient from SMART launch context'

      input :patient_id

      run do
        fhir_read(:patient, patient_id)

        assert_response_status(200)
        assert_resource_type(:patient)
      end
    end
  end
end
```

### Discovery Group

The Discovery Group ([STU1](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/discovery_stu1_group.rb)
and [STU2](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/discovery_stu2_group.rb))
examines a server's CapabilityStatement and `.well-known/smart-configuration`
endpoint to determine its configuration.

**ids:** `smart_discovery`, `smart_discovery_stu2`

**inputs:** `url`

**outputs:**
* `well_known_configuration` - The contents of `.well-known/smart-configuration`
* `smart_authorization_url`
* `smart_introspection_url`
* `smart_management_url`
* `smart_registration_url`
* `smart_revocation_url`
* `smart_token_url`

### Standalone Launch Group

The Standalone Launch Group ([STU1](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/standalone_launch_group.rb)
and [STU2](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/standalone_launch_group_stu2.rb))
performs the entire standalone launch workflow.

**ids:** `smart_standalone_launch`, `smart_standalone_launch_stu2`

**inputs:** `url`, `client_id`, `client_secret`, `requested_scopes`

**outputs:**
* `smart_credentials` - An [OAuthCredentials
  Object](https://inferno-framework.github.io/inferno-core/docs/Inferno/DSL/OAuthCredentials.html)
  containing the credentials obtained from the launch.
* `token_retrieval_time`
* `id_token`
* `refresh_token`
* `access_token`
* `expires_in`
* `patient_id`
* `encounter_id`
* `received_scopes`
* `intent`

**options:**
* `redirect_uri`: You should not have to manually set this if the `INFERNO_HOST`
  environment variable is set.
* `ignore_missing_scopes_check`: Forego checking that the scopes granted by the
 token match those requested.

### EHR Launch Group

The EHR Launch Group ([STU1](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/ehr_launch_group.rb)
and [STU2](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/ehr_launch_group_stu2.rb))
performs the entire EHR launch workflow.

**ids:** `smart_ehr_launch`, `smart_ehr_launch_stu2`

**inputs:** `url`, `client_id`, `client_secret`, `requested_scopes`

**outputs:**
* `smart_credentials` - An [OAuthCredentials
  Object](https://inferno-framework.github.io/inferno-core/docs/Inferno/DSL/OAuthCredentials.html)
  containing the credentials obtained from the launch.
* `token_retrieval_time`
* `id_token`
* `refresh_token`
* `access_token`
* `expires_in`
* `patient_id`
* `encounter_id`
* `received_scopes`
* `intent`

**options:**
* `launch`: a hardcoded value to use instead of the `launch` parameter received
  during the launch
* `redirect_uri`: You should not have to manually set this if the `INFERNO_HOST`
  environment variable is set.
* `launch_uri`: You should not have to manually set this if the `INFERNO_HOST`
  environment variable is set.
* `ignore_missing_scopes_check`: Forego checking that the scopes granted by the
 token match those requested.

### OpenID Connect Group
[The OpenID Connect
Group](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/openid_connect_group.rb)
validates an id token obtained during a SMART launch.

**id:** `smart_openid_connect`

**inputs:** `id_token`, `client_id`, `requested_scopes`, `access_token`,
`smart_credentials`

**outputs:**
* `id_token_payload_json`
* `id_token_header_json`
* `openid_configuration_json`
* `openid_issuer`
* `openid_jwks_uri`
* `openid_jwks_json`
* `openid_rsa_keys_json`
* `id_token_jwk_json`
* `id_token_fhir_user`

### Token Refresh Group

[The Token Refresh
Group](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/token_refresh_group.rb)
performs a token refresh.

**id:** `smart_token_refresh`

**inputs:** `refresh_token`, `client_id`, `client_secret`, `received_scopes`,
`well_known_token_url`

**outputs:**
* `smart_credentials` - An [OAuthCredentials
  Object](https://inferno-framework.github.io/inferno-core/docs/Inferno/DSL/OAuthCredentials.html)
  containing the credentials obtained from the launch.
* `token_retrieval_time`
* `refresh_token`
* `access_token`
* `expires_in`
* `received_scopes`

**options:**
* `include_scopes`: (`true/false`) Whether to include scopes in the refresh
  request

### Backend Services Authorization Group
The [Backend Services Authorization Group](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/backend_services_authorization_group.rb)
is only part of SMART App Launch STU 2.0. It is used when autonomous or
semi-autonomous backend services (clients) need to access resources from FHIR
servers that have pre-authorized, defined scopes of access.  This group appplies
a client credentials flow using confidential client asymmetric
authentication and JSON Web Token (JWT) assertions to retrieve an access token
for system resources.

**id:** `backend_services_authorization`

**inputs:** `smart_token_url`, `backend_services_client_id`,
`backend_services_requested_scope`, `client_auth_encryption_method`, `backend_services_jwks_kid` (optional)

**outputs:**  `bearer_token`

### Token Introspection Group 
The [Token Introspection Group](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/token_introspection_group.rb)
is only part of SMART App Launch STU 2.0 and is divided into three subgroups that
can be run collectively or independently, depending on the constraints of the environment
under test. 

**id:** `smart_token_introspection`

#### Token Introspection Access Token Group
The [Token Introspection Access Token Group](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/token_introspection_access_token_group.rb) 
reuses tests from the Discovery and Standalone Launch groups to retrieve the
token endpoint and an access token for introspection.  This group is optional.   

**id:** `smart_token_introspection_access_token_group`

**inputs:** `url`, `client_id`, `client_secret`, `requested_scopes`, `use_pkce`,
`pkce_code_challenge_method`, `authorization_method`, `client_auth_type`, `client_auth_encryption_method`

**outputs:** `standalone_access_token`

#### Token Introspection Request Group
The [Token Introspection Request Group](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/token_introspection_request_group.rb) 
sends introspection requests for both a valid and invalid access token to the
authorization server and ensure the appropriate HTTP response is returned.  This
group is optional but recommended. 

**id:** `smart_token_introspection_request_group`

**inputs:** `well_known_introspection_url`, `custom_authorization_header`,
`optional_introspection_request_params`, `standalone_access_token` 

**outputs:**
* `active_token_introspection_response_body`
* `invalid_token_introspection_response_body`

#### Token Introspection Response Group
The [Token Introspection Response Group](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/token_introspection_response_group.rb)
validates the token introspection responses returned from the authorization
server.  This group is required to demonstrate token introspection capabilities. 

**id:** `smart_token_introspection_response_group`

**inputs:** `standalone_client_id`, `standalone_received_scopes`,
`standalone_id_token`, `standalone_patient_id`, `standalone_encounter_id`,
`active_token_introspection_response_body`,
`invalid_token_introspection_response_body`

**outputs:** none


## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

## Trademark Notice

HL7, FHIR and the FHIR [FLAME DESIGN] are the registered trademarks of Health
Level Seven International and their use does not constitute endorsement by HL7.
