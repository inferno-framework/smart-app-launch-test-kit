require_relative 'app_redirect_test_stu2'
require_relative 'ehr_launch_group'
require_relative 'token_exchange_stu2_test'

module SMARTAppLaunch
  class EHRLaunchGroupSTU2 < EHRLaunchGroup
    id :smart_ehr_launch_stu2
    description %(
      # Background

      The [EHR
      Launch](http://hl7.org/fhir/smart-app-launch/STU2/app-launch.html#launch-app-ehr-launch)
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

      * [SMART EHR Launch Sequence](http://hl7.org/fhir/smart-app-launch/STU2/app-launch.html#launch-app-ehr-launch)
    )

    config(
      inputs: {
        smart_auth_info: {
          name: :ehr_smart_auth_info,
          options: {
            components: [
              {
                name: :requested_scopes,
                default: 'launch openid fhirUser offline_access patient/*.rs'
              },
              {
                name: :pkce_support,
                default: 'enabled',
                locked: true
              },
              {
                name: :pkce_code_challenge_method,
                default: 'S256',
                locked: true
              },
              Inferno::DSL::AuthInfo.default_auth_type_component_without_backend_services,
              {
                name: :use_discovery,
                locked: true
              }
            ]
          }
        }
      }
    )

    test from: :smart_app_redirect_stu2 do
      input :launch
    end

    redirect_index = children.find_index { |child| child.id.to_s.end_with? 'app_redirect' }
    children[redirect_index] = children.pop

    test from: :smart_token_exchange_stu2

    token_exchange_index = children.find_index { |child| child.id.to_s.end_with? 'token_exchange' }
    children[token_exchange_index] = children.pop

    children[token_exchange_index].id(:smart_token_exchange)
  end
end
