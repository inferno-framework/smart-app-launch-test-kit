require_relative 'ehr_launch_group_stu2'
require_relative 'token_response_body_test_stu2_2'

module SMARTAppLaunch
  class EHRLaunchGroupSTU22 < EHRLaunchGroupSTU2
    id :smart_ehr_launch_stu2_2
    description %(
      # Background

      The [EHR
      Launch](http://hl7.org/fhir/smart-app-launch/STU2.2/app-launch.html#launch-app-ehr-launch)
      is one of two ways in which an app can be launched, the other being
      Standalone launch. In an EHR launch, the app is launched from an
      existing EHR session or portal by a redirect to the registered launch
      URL. The EHR provides the app two parameters:

      * `iss` - Which contains the FHIR server url
      * `launch` - An identifier needed for authorization

      # Test Methodology

      Inferno will wait for the EHR server redirect upon execution. When the
      redirect is received Inferno will check for the presence of the `iss`
      and `launch` parameters. The security of the authorization endpoint is
      then checked and authorization is attempted using the provided `launch`
      identifier.

      For more information on the #{title} see:

      * [SMART EHR Launch Sequence](http://hl7.org/fhir/smart-app-launch/STU2.2/app-launch.html#launch-app-ehr-launch)
    )

    config(
      inputs: {
        use_pkce: {
          default: 'true',
          locked: true
        },
        pkce_code_challenge_method: {
          default: 'S256',
          locked: true
        },
        requested_scopes: {
          default: 'launch openid fhirUser offline_access user/*.rs'
        }
      }
    )

    test from: :smart_token_response_body_stu2_2

    token_response_body_index = children.find_index { |child| child.id.to_s.end_with? 'token_response_body' }
    children[token_response_body_index] = children.pop
  end
end
