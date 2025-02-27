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

    input :authorization_method,
          title: 'Authorization Request Method',
          type: 'radio',
          default: 'get',
          options: {
            list_options: [
              {
                label: 'GET',
                value: 'get'
              },
              {
                label: 'POST',
                value: 'post'
              }
            ]
          }

    def default_post_authorization_uri
      "#{Inferno::Application['base_url']}/custom/smart_stu2/post_auth"
    end

    def post_authorization_uri
      config.options[:post_authorization_uri].presence || default_post_authorization_uri
    end

    def authorization_url_builder(url, params)
      return super if authorization_method == 'get'

      post_params = params.merge(auth_url: url)

      post_url = URI(post_authorization_uri)
      post_url.query = URI.encode_www_form(post_params)
      post_url.to_s
    end
  end
end
