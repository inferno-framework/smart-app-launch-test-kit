module SMARTAppLaunch
  class LaunchReceivedTest < Inferno::Test
    title 'EHR server sends launch parameter'
    description %(
      The `launch` URL parameter associates the app's authorization request with
      the current EHR session.
    )
    id :smart_launch_received

    output :launch
    uses_request :launch

    run do
      launch = request.query_parameters['launch']
      output launch: launch

      assert launch.present?, 'No `launch` paramater received'
    end
  end
end
