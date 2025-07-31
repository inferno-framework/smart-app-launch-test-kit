module SMARTAppLaunch
  class ContextDataRequestsAttestationTest < Inferno::Test
    title 'Complies with requirements for requesting context data'
    id :context_data_requests
    description %(
      The client application complying with requirements for requesting context data:
      - Asks for "launch context" scopes when requesting access to context data
      - Begins scope string with `launch` when requesting access to context data
      - Uses `launch/patient` scope for patient context at launch time
      - Uses `launch/encounter` scope for encounter context launch time
      - Converts the type names to all lowercase when specifying resource types for additional launch contexts
      - Solicits launch context with a specific role by appending `?role={role}` to the end of the launch context scope
        when the same resource type might be used for more than one purpose
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@150',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@151',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@152',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@153',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@155',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@156'

    input :context_data_requests_correct,
          title: 'Complies with requirements for requesting context data',
          description: %(
            I attest that the client application complies with requirements for requesting context data:
            - Asks for "launch context" scopes when requesting access to context data
            - Begins scope string with `launch` when requesting access to context data
            - Uses `launch/patient` scope for patient context at launch time
            - Uses `launch/encounter` scope for encounter context launch time
            - Converts the type names to all lowercase when specifying resource types for additional launch contexts
            - Solicits launch context with a specific role by appending `?role={role}` to the end of the launch context
              scope when the same resource type might be used for more than one purpose
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
    input :context_data_requests_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert context_data_requests_correct == 'true',
             'Client application does not comply with requirements for requesting context data.'
      pass context_data_requests_note if context_data_requests_note.present?
    end
  end
end
