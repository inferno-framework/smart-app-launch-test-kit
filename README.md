# Inferno SMART App Launch Test Kit 

This is a collection of tests for the [SMART Application Launch Framework
Implementation Guide](http://hl7.org/fhir/smart-app-launch/index.html) using the
[Inferno FHIR testing tool](https://github.com/inferno-community/inferno-core).

## Instructions

- Clone this repo.
- Run `setup.sh` in this repo.
- Run `run.sh` in this repo.
- Navigate to `http://localhost**. The SMART test suite will be available.

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
    title 'Make some FHIR requests using SMART credentials'
    
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

[The Discovery
Group](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/discovery_group.rb)
examines a server's CapabilityStatement and `.well-known/smart-configuration`
endpoint to determine its configuration.

**id:** `smart_discovery`

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

[The Standalone Launch
Group](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/standalone_launch_group.rb)
performs the entire standalone launch workflow.

**id:** `smart_standalone_launch`

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

### EHR Launch Group

[The EHR Launch
Group](https://github.com/inferno-framework/smart-app-launch-test-kit/blob/main/lib/smart_app_launch/ehr_launch_group.rb)
performs the entire EHR launch workflow.

**id:** `smart_standalone_launch`

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

## License
Copyright 2022 The MITRE Corporation

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
