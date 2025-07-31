module SMARTAppLaunch
  class LaunchURLParameterAttestationTest < Inferno::Test
    title 'Receives `launch` URL parameter when launched from the EHR'
    id :launch_url_param
    description %(
      The client application is passed an explicit URL parameter called `launch`, whose value must associate the app’s
      authorization request with the current EHR session when launched from the EHR.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@161'
  end
end
