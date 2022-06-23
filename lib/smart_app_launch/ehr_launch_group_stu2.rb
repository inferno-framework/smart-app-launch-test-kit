require_relative 'ehr_launch_group'

module SMARTAppLaunch
  class EHRLaunchGroupSTU2 < EHRLaunchGroup
    id :smart_ehr_launch_stu2
    description %(
      # Background

      The [EHR
      Launch](https://www.hl7.org/fhir/smart-app-launch/1.0.0/index.html#ehr-launch-sequence)
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

      * [SMART EHR Launch Sequence](https://www.hl7.org/fhir/smart-app-launch/1.0.0/index.html#ehr-launch-sequence)
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
        }
      }
    )
  end
end
