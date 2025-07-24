module SMARTAppLaunch
  class ScopeAccessAttestationTest < Inferno::Test
    title 'Respects underlying system policies even with conflicting scopes'
    id :scope_access
    description %(
      The server respects underlying system policies and permissions even if they conflict with granted scopes when
      responding to a client request of a specific set of access rights.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@119'

    input :scope_access_correct,
          title: 'Respects underlying system policies even with conflicting scopes',
          description: %(
            I attest that the server respects underlying system policies and permissions even if they conflict with
            granted scopes when responding to a client request of a specific set of access rights.
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
    input :scope_access_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert scope_access_correct == 'true',
             'Server does not respect underlying system policies even with conflicting scopes.'
      pass scope_access_note if scope_access_note.present?
    end
  end
end