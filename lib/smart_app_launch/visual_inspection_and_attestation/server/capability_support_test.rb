module SMARTAppLaunch
  class ServerCapabilitiesAttestationTest < Inferno::Test
    title 'Supports capabilities that are listed'
    id :server_capabilities
    description %(
      The server supports the following capabilities when they are listed:
      - Supports SMART's EHR launch mode when listing the `launch-ehr` capability
      - Supports SMART's Standalone launch mode when listing the `launch-standalone` capability
      - Supports POST-based authorization when listing the `authorize-post` capability
      - Supports SMART's public client profile (no client authentication) when listing the `client-public` capability
      - Supports SMART's symmetric confidential client profile ("client secret" authentication) when listing the
        `client-confidential-symmetric` capability
      - Supports SMART's asymmetric confidential client profile ("JWT authentication") when listing the
        `client-confidential-asymmetric` capability
      - Supports SMART's OpenID Connect profile when listing the `sso-openid-connect` capability
      - Supports "need patient banner" launch context (conveyed via need_patient_banner token parameter) when listing
        the `context-banner` capability
      - Supports `SMART style URL` launch context (conveyed via smart_style_url token parameter) when listing the
        `context-style` capability
      - Supports patient-level launch context (requested by `launch/patient` scope, conveyed via patient token
        parameter) when listing the `context-ehr-patient` capability
      - Supports encounter-level launch context (requested by `launch/encounter` scope, conveyed via `encounter` token
        parameter) when listing the `context-ehr-encounter` capability
      - Supports patient-level launch context (requested by `launch/patient` scope, conveyed via `patient` token
        parameter) when listing the `context-standalone-patient` capability
      - Supports encounter-level launch context (requested by `launch/encounter` scope, conveyed via `encounter` token
        parameter) when listing the `context-standalone-encounter` capability
      - Supports "offline" refresh tokens (requested by `offline_access` scope) when listing the `permission-offline`
        capability
      - Supports "online" refresh tokens requested during EHR Launch (requested by `online_access` scope) when listing
        the `permission-online` capability
      - Supports patient-level scopes (e.g., `patient/Observation.rs`) when listing the `permission-patient` capability
      - Supports user-level scopes (e.g., `user/Appointment.rs`) when listing the `permission-user` capability
      - Supports SMARTv1 scope syntax (e.g., patient/Observation.read) when listing the `permission-v1` capability
      - Supports SMARTv2 granular scope syntax (e.g., `patient/Observation.rs?category=http://terminology.hl7.org/CodeSystem/observation-category|vital-signs`)
        when listing the `permission-v2` capability
      - Supports managing SMART App State when listing the `smart-app-state` capability
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@352',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@353',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@354',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@355',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@356',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@357',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@358',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@359',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@360',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@361',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@362',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@363',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@364',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@365',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@366',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@366',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@367',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@368',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@369',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@370',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@371'

    input :capability_support,
          title: 'Supports capabilities that it lists',
          description: %(
            I attest that the server supports capabilities that it lists.
          ),
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Yes',
                value: 'true'
              },
              {
                label: 'No',
                value: 'false'
              }
            ]
          }
    input :capability_support_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert capability_support == 'true',
             'Server did not support all capabilities that it lists.'
      pass capability_support_note if capability_support_note.present?
    end
  end
end