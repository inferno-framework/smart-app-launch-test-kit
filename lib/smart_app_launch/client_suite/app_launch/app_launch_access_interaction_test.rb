require 'rack/utils'
require_relative '../../urls'
require_relative '../../endpoints/mock_smart_server'

module SMARTAppLaunch
  class SMARTClientAppLaunchAccessInteraction < Inferno::Test
    include URLs

    id :smart_client_app_launch_access_interaction
    title 'Perform SMART-secured Access'
    description %(
      During this test, Inferno will wait for the client to be launched,
      perform the authorization code flow to obtain an access token,
      and access FHIR data.
    )
    input :client_id,
          title: 'Client Id',
          type: 'text',
          locked: true,
          description: %(
            The registered Client Id for use in obtaining access tokens.
            Create a new session if you need to change this value.
          )
    input :smart_launch_urls,
          title: 'SMART App Launch URL(s)',
          type: 'textarea',
          description: %(
            Registered Launch URLs in the form of a comma-separated list of zero or more URLs. If present,
            Inferno will provide an option to use each to launch the app.
            Create a new session if you need to change this value.
          ),
          locked: true,
          optional: true
    input :client_type,
          title: 'Client Authentication Type',
          type: 'text',
          description: %(
            Authentication approach chosen during client registration.
            Create a new session if you need to change this value.
          ),
          locked: true
    input :smart_jwk_set,
          title: 'Confidential Asymmetric JSON Web Key Set (JWKS)',
          type: 'textarea',
          optional: true,
          locked: true,
          description: %(
            Only populated for Confidential Asymmtric clients. The SMART client's JSON Web Key Set in the form of
            either a publicly accessible url containing the JWKS, or the raw JWKS JSON. Must include the key(s)
            Inferno will need to verify signatures on token requests made by the client.
            Create a new session if you need to change this value.
          )
    input :smart_client_secret,
          title: 'SMART Confidential Symmetric Client Secret',
          type: 'textarea',
          description: %(
            Only populated for Confidential Asymmetric clients. The client secret that will be provided
            during token requests to authenticate the client to Inferno.
            Create a new session if you need to change this value.
          ),
          locked: true,
          optional: true
    input :echoed_fhir_response,
          title: 'FHIR Response to Echo',
          type: 'textarea',
          description: %(
            JSON representation of a FHIR resource for Inferno to echo when a request
            is made to the simulated FHIR server. The provided content will be echoed
            back exactly and no check will be made that it is appropriate for the request
            made. If nothing is provided, an OperationOutcome will be returned.
          ),
          optional: true

    output :launch_key

    run do
      
      message = 
        if smart_launch_urls.present?
          launch_key = SecureRandom.hex(32)
          output(launch_key:)

          launch_query_string = Rack::Utils.build_query({ iss: client_fhir_base_url, launch: launch_key })
          ehr_launch_locations = smart_launch_urls.split(',').map { |launch_url| "#{launch_url}?#{launch_query_string}"}
          ehr_launch_links_string = ehr_launch_locations.map { |url| "- [launch](#{url})"}.join("\n")

          prefix = %(
            **Launch and Access**

            The app has been registered with Inferno's simulated SMART server as a
            #{client_type} client with client id #{client_id}.
            
            Perform a standalone launch to connect to Inferno's simulated FHIR server at

            `#{client_fhir_base_url}`
            
            Or open one of the following links in a new tab to perform an EHR launch:
          )
          suffix = %(
          
            [Click here](#{client_resume_pass_url}?token=#{client_id}) once you have completed
            the launch and access.
          )
          prefix + ehr_launch_links_string + suffix
        else
          %(
            **Launch and Access**

            The app has been registered with Inferno's simulated SMART server as a
            #{client_type} client with client id #{client_id}.
            
            Perform a standalone launch to connect to Inferno's simulated FHIR server at

            `#{client_fhir_base_url}`

            [Click here](#{client_resume_pass_url}?token=#{client_id}) once you have completed
            the launch and access.
          )
        end

      wait(
        identifier: client_id,
        message:
      )
    end
  end
end
