module SMARTAppLaunch
  class BackendServicesScopes < Inferno::Test
    title ''
    id :backend_services_scopes
    description %(
      - Pre-authorizes the client/associated the client with the authority to access certain data
      - Applies the set of scopes received in the access token request from the client as additional access restrictions
        following the SMART Scopes syntax
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@240',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@241'
  end
end