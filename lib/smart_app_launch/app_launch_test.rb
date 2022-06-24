module SMARTAppLaunch
  class AppLaunchTest < Inferno::Test
    title 'EHR server redirects client browser to Inferno app launch URI'
    description %(
      Client browser sent from EHR server to app launch URI of client app as
      described in SMART EHR Launch Sequence.
    )
    id :smart_app_launch

    input :url
    receives_request :launch

    config options: { launch_uri: "#{Inferno::Application['base_url']}/custom/smart/launch" }

    def wait_message
      %(
        ### #{title}

        Waiting for Inferno to be launched from the EHR.

        Tests will resume once Inferno receives a launch request at
        `#{config.options[:launch_uri]}` with an `iss` of `#{url}`.
      )
    end

    run do
      wait(
        identifier: url,
        message: wait_message
      )
    end
  end
end
