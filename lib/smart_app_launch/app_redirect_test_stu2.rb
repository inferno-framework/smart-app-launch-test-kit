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

    input :auth_info,
          type: :auth_info,
          options: {
            mode: 'auth',
            components: [
              {
                name: :auth_type,
                type: 'select',
                default: 'public',
                options: {
                  list_options: [
                    {
                      label: 'Public',
                      value: 'public'
                    },
                    {
                      label: 'Confidential Symmetric',
                      value: 'symmetric'
                    },
                    {
                      label: 'Confidential Asymmetric',
                      value: 'asymmetric'
                    }
                  ]
                }
              },
              {
                name: :pkce_support,
                default: 'enabled',
                locked: true
              },
              {
                name: :pkce_code_challenge_method,
                default: 'S256',
                locked: true
              },
              {
                name: :requested_scopes,
                type: 'textarea'
              },
              {
                name: :use_discovery,
                locked: true
              }
            ]
          }

    def authorization_url_builder(url, params)
      return super if auth_info.auth_request_method == 'get'

      post_params = params.merge(auth_url: url)

      post_url = URI(config.options[:post_authorization_uri])
      post_url.query = URI.encode_www_form(post_params)
      post_url.to_s
    end
  end
end
