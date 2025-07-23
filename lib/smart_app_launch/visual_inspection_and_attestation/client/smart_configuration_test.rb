module SMARTAppLaunch
  class SmartConfigurationAttestationTest < Inferno::Test
    title 'Discovers and retrieves EHR FHIR server\'s SMART configuration'
    id :smart_configuration
    description %(
      Client applications interact with an EHR FHIR server's SMART configuration by:
      - Discovering the SMART configuration metadata, including OAuth token endpoint URL
      - Retrieves the SMART configuration file from [base]/.well-known/smart-configuration
        with an HTTP GET with an `Accept` header supporting `application/json`
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@226',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@227'

    input :smart_config_metadata,
          title: 'Discovers the SMART configuration metadata, including OAuth token endpoint URL',
          description: %(
            I attest that the client application discovers an EHR FHIR server's SMART configuration metadata,
            including the OAuth token endpoint URL.
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
    input :smart_config_metadata_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    input :smart_config_retrieve,
          title: 'Retrieves SMART configuration file from [base]/.well-known/smart-configuration',
          description: %(
            I attest that the client application retrieves the SMART configuration file from
            [base]/.well-known/smart-configuration with an HTTP GET with an `Accept` header supporting
            `application/json`.
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
    input :smart_config_retrieve_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert smart_config_metadata == 'true',
             'Client application did discover the SMART configuration metadata with OAuth token endpoint URL.'
      pass smart_config_metadata_note if smart_config_metadata_note.present?

      assert smart_config_retrieve == 'true',
             'Client application did not retrieve the SMART configuration file from
             [base]/.well-known/smart-configuration.'
      pass smart_config_retrieve_note if smart_config_retrieve_note.present?
    end
  end
end