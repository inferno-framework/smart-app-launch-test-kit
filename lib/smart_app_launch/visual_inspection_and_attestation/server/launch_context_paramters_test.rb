module SMARTAppLaunch
  class LaunchContextParametersAttestationTest < Inferno::Test
    title 'Supports launch context parameters'
    id :launch_context_parameters
    description %(
      Servers support the following launch context parameters:
      - `patient` contains a string value with a patient id, indicating that the app was launched in the context of
        FHIR Patient
      - `encounter` contains a string value with an encounter id, indicating that the app was launched in the context of
        FHIR Encounter
      - `need_patient_banner` contains a boolean value indicating whether the app was launched in a UX context where a
        patient banner is required (when true) or may not be required (when false)
      - `intent` contains a string value describing the intent of the application launch
      - `smart_style_url` contains a string URL where the EHR's style parameters can be retrieved (for apps that support
         styling)
      - `tenant` contains a string conveying an opaque identifier for the healthcare organization that is launching the
         app
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@170',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@171',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@173',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@174',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@175',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@176'

    input :launch_context_params,
          title: 'Supports launch context parameters',
          description: %(
            I attest that the server supports the following launch context parameters:
            - `patient` contains a string value with a patient id, indicating that the app was launched in the context of
              FHIR Patient
            - `encounter` contains a string value with an encounter id, indicating that the app was launched in the context of
              FHIR Encounter
            - `need_patient_banner` contains a boolean value indicating whether the app was launched in a UX context where a
              patient banner is required (when true) or may not be required (when false)
            - `intent` contains a string value describing the intent of the application launch
            - `smart_style_url` contains a string URL where the EHR's style parameters can be retrieved (for apps that support
              styling)
            - `tenant` contains a string conveying an opaque identifier for the healthcare organization that is launching the
              app
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
    input :launch_context_params_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert launch_context_params == 'true',
             'Server did not support all launch context parameters.'
      pass launch_context_params_note if launch_context_params_note.present?
    end
  end
end