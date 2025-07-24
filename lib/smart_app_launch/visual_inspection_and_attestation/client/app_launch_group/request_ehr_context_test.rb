module SMARTAppLaunch
  class RequestEHRContextAttestationTest < Inferno::Test
    title 'Requests EHR context when launched outside the EHR'
    id :request_ehr_context
    description %(
      The client application launched outside the EHR does not have nay EHR context at the set and therefore explicitly
      requests EHR context.
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@166'
  end
end
