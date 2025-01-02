require 'uri'
require_relative 'app_redirect_test'

module SMARTAppLaunch
  class AppRedirectTestSTU2 < AppRedirectTest
    id :smart_app_redirect_stu2
    description %(
      Client browser redirected from OAuth server to redirect URI of client
      app as described in SMART authorization sequence.

      Client SHALL use either the HTTP GET or the HTTP POST method to send the
      Authorization Request to the Authorization Server.

      [Authorization Code
      Request](http://hl7.org/fhir/smart-app-launch/STU2/app-launch.html#request-4)
    )

    input :smart_auth_info, type: :auth_info, options: { mode: 'auth' }

    def authorization_url_builder(url, params)
      return super if smart_auth_info.auth_request_method.casecmp? 'get'

      post_params = params.merge(auth_url: url)

      post_url = URI(config.options[:post_authorization_uri])
      post_url.query = URI.encode_www_form(post_params)
      post_url.to_s
    end
  end
end
