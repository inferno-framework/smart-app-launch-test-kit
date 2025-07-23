module SMARTAppLaunch
  class ScopeAccessAttestation < Inferno::Test
    title ''
    id :scope_access
    description %(
      - Respect underlying system policies and permissions even if they conflict with granted scopes when responding to a client request of a specific set of access rights.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@119'
  end
end