# frozen_string_literal: true

require 'rack/utils'

module SMARTAppLaunch
  RE_RUN_REGISTRATION_SUFFIX =
    'Create a new session and re-run the Client Registration group if you need to change this value.'
  INPUT_CLIENT_ID_DESCRIPTION =
    'Testers may provide a specific value for Inferno to assign as the client id. If no value is provided, ' \
    'the Inferno session id will be used.'
  INPUT_CLIENT_ID_DESCRIPTION_LOCKED =
    "The registered Client Id for use in obtaining access tokens. #{RE_RUN_REGISTRATION_SUFFIX}".freeze
  INPUT_SMART_LAUNCH_URLS_DESCRIPTION =
    'If the client app supports EHR launch, a comma-delimited list of one or more URLs that Inferno can ' \
    'use to launch the app.'
  INPUT_SMART_LAUNCH_URLS_DESCRIPTION_LOCKED =
    'Registered Launch URLs in the form of a comma-separated list of zero or more URLs. If present, Inferno ' \
    "will provide an option to use each to launch the app. #{RE_RUN_REGISTRATION_SUFFIX}".freeze
  INPUT_SMART_REDIRECT_URIS_DESCRIPTION =
    'A comma-separated list of one or more URIs that the app will sepcify as the target of the redirect for ' \
    'Inferno to use when providing the authorization code.'
  INPUT_SMART_REDIRECT_URIS_DESCRIPTION_LOCKED =
    'Registered Redirect URIs in the form of a comma-separated list of one or more URIs. Redirect URIs ' \
    "specified in authorization requests must come from this list. #{RE_RUN_REGISTRATION_SUFFIX}".freeze
  INPUT_CLIENT_SECRET_DESCRIPTION =
    'Provide the client secret that the confidential symmetric client will send with token requests ' \
    'to authenticate the client to Inferno.'
  INPUT_CLIENT_SECRET_DESCRIPTION_LOCKED =
    'The registered client secret that will be provided during token requests to authenticate the client ' \
    "to Inferno. #{RE_RUN_REGISTRATION_SUFFIX}".freeze
  INPUT_CLIENT_JWKS_DESCRIPTION =
    'The SMART client\'s JSON Web Key Set including the key(s) Inferno will need to verify signatures ' \
    'on token requests made by the client. May be provided as either a publicly accessible url containing ' \
    'the JWKS, or the raw JWKS JSON.'
  INPUT_CLIENT_JWKS_DESCRIPTION_LOCKED =
    'The SMART client\'s JSON Web Key Set in the form of either a publicly accessible url containing the ' \
    'JWKS, or the raw JWKS JSON. Must include the key(s) Inferno will need to verify signatures on token ' \
    "requests made by the client. #{RE_RUN_REGISTRATION_SUFFIX}".freeze

  INPUT_LAUNCH_CONTEXT_DESCRIPTION =
    'Launch context details to be included in access token responses, specified as a JSON array. If provided, ' \
    'the contents will be merged into Inferno\'s token responses.'
  INPUT_FHIR_USER_RELATIVE_REFERENCE =
    'A FHIR relative reference (<resource type>/<id>) for the FHIR user record to return when the openid ' \
    'and fhirUser scopes are requested. Include this resource in the **Available Resources** input so ' \
    'that it can be accessed via FHIR read.'
  INPUT_FHIR_READ_RESOURCES_BUNDLE_DESCRIPTION =
    'Resources to make available in Inferno\'s simulated FHIR server provided as a FHIR bundle. Each entry ' \
    'must contain a resource with the id element populated. Each instance present will be available for ' \
    'retrieval from Inferno at the endpoint: <fhir-base>/<resource type>/<instance id>. These will only ' \
    'be available through the read interaction.'
  INPUT_ECHOED_FHIR_RESPONSE_DESCRIPTION =
    'JSON representation of a default FHIR resource for Inferno to echo when a request is made to the ' \
    'simulated FHIR server. Reads targetting resources in the **Available Resources** input will return ' \
    'that resource instead of this. Otherwise, the content here will be echoed back exactly and no check ' \
    'will be made that it is appropriate for the request made. If nothing is provided, an OperationOutcome ' \
    'indicating nothing to echo will be returned.'

  module ClientWaitDialogDescriptions
    def access_wait_dialog_backend_services_access_prefix(client_id, fhir_base_url)
      <<~PREFIX
        **Access**

        Use the registered client id (#{client_id}) to obtain an access
        token using SMART Backend Services
        and use that token to access a FHIR endpoint under the simulated server's base URL:

        `#{fhir_base_url}`

      PREFIX
    end

    def access_wait_dialog_app_launch_access_prefix(client_id, authentication_approach, fhir_base_url)
      <<~PREFIX
        **Launch and Access**

        The app has been registered with Inferno's simulated SMART server as a
        #{authentication_approach} client with client id `#{client_id}`.

        Perform a standalone launch to connect to Inferno's simulated FHIR server at:

        `#{fhir_base_url}`

      PREFIX
    end

    def access_wait_dialog_ehr_launch_instructions(smart_launch_urls, fhir_base_url)
      if smart_launch_urls.present?
        launch_key = SecureRandom.hex(32)
        output(launch_key:)

        launch_query_string = Rack::Utils.build_query({ iss: fhir_base_url, launch: launch_key })
        ehr_launch_locations = smart_launch_urls.split(',').map { |launch_url| "#{launch_url}?#{launch_query_string}" }
        ehr_launch_links_string = ehr_launch_locations.map { |url| "- [launch](#{url})" }.join("\n")

        "\n\nOr open one of the following links in a new tab to perform an EHR launch:\n#{ehr_launch_links_string}\n\n"
      else
        ''
      end
    end

    def access_wait_dialog_access_response_and_continue_suffix(client_id, resume_pass_url)
      <<~SUFFIX
        Inferno will respond to requests with either:
        - A resource from the Bundle in the **Available Resources** input if the request is a read matching
          a resource type and id found in the Bundle.
        - Otherwise, the contents of the **Default FHIR Response** if provided.
        - Otherwise, an OperationOutcome indicating nothing to echo.

        [Click here](#{resume_pass_url}?token=#{client_id}) once the client has made a data access request.
      SUFFIX
    end
  end
end
