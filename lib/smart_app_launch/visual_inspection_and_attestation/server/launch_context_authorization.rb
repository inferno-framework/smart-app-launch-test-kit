module SMARTAppLaunch
  class LaunchContextAuthorizationAttestation < Inferno::Test
    title ''
    id :launch_context_authorization
    description %(
      - Includes any context data the app requested and any (potentially) unsolicited context data the EHR may decide to
        communicate in the token response
      - Includes any launch context parameters and come alongside the the access token which appear as JSON parameters
        in the token response
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@168',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@169'
  end
end