module SMARTAppLaunch
  class SmartConfigurationAttestationTest < Inferno::Test
    title 'Discovers and retrieves EHR FHIR server\'s SMART configuration'
    id :smart_configuration
    description %(
      The client application discovers and retrieves an EHR FHIR server's SMART configuration by:
      - Discovering the SMART configuration metadata, including OAuth token endpoint URL
      - Retrieves the SMART configuration file from [base]/.well-known/smart-configuration
        with an HTTP GET with an `Accept` header supporting `application/json`
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@226',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@227'

    input :smart_configuration_correct,
          title: 'Discovers and retrieves EHR FHIR server\'s SMART configuration',
          description: %(
            I attest that the client application discovers and retrieves an EHR FHIR server's SMART configuration by:
            - Discovering the SMART configuration metadata, including OAuth token endpoint URL
            - Retrieves the SMART configuration file from [base]/.well-known/smart-configuration
              with an HTTP GET with an `Accept` header supporting `application/json`
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
    input :smart_configuration_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert smart_configuration_correct == 'true',
             'Client application does not discover or retrieve an EHR FHIR server\'s SMART configuration.'
      pass smart_configuration_correct if smart_configuration_correct.present?
    end
  end
end
