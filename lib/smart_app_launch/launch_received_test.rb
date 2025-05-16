module SMARTAppLaunch
  class LaunchReceivedTest < Inferno::Test
    title 'EHR server sends launch parameter'
    description %(
      The `launch` URL parameter associates the app's authorization request with
      the current EHR session.
    )
    id :smart_launch_received

    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@161'

    output :launch
    uses_request :launch

    run do
      launch = request.query_parameters['launch']
      output launch: launch

      assert launch.present?, 'No `launch` parameter received'
    end
  end
end
