module SMARTAppLaunch
  class WellKnownSMARTConfigurationAttestationTest < Inferno::Test
    title 'Discovers the server\'s metadata with the .well-known/smart-configuration endpoint'
    id :well_known_smart_config
    description %(
      Client applications discover the EHR FHIR server's configuration metadata by appending
      .well-known/smart-configuration to the FHIR Base URL with an Accept header support application/json.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@29'

    input :well_known_smart_config_discover,
          title: 'Discovers the server\'s metadata with the .well-known/smart-configuration endpoint',
          description: %(
            I attest that the client application discovers the EHR FHIR server's configuration metadata by appending
            .well-known/smart-configuration to the FHIR Base URL with an Accept header support application/json.
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
    input :well_known_smart_config_discover_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert well_known_smart_config_discover == 'true',
             'Client application did not discover the EHR FHIR server\'s metadata with .well-known/smart-configuration.'
      pass well_known_smart_config_discover_note if well_known_smart_config_discover_note.present?
    end
  end
end