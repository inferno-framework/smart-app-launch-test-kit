module SMARTAppLaunch
  class WellKnownSmartConfigurationRequestAttestationTest < Inferno::Test
    title 'Adheres to guidelines for requests to the `/.well-known/smart-configuration` endpoint'
    id :well_known_smart_config_request
    description %(
      Servers adhere to the following guidelines for requests to the `/.well-known/smart-configuration` endpoint:
      - Responds with a discovery response that meets requirements described in `client-confidential-asymmetric`
        authentication
      - Includes absolute URLs in the response document from `/.well-known/smart-configuration` requests
      - Requires `grant_types_supported` and that it contains the Array of grant types supported at the token
        endpoint when responding to a `/.well-known/smart-configuration` request. The options are “authorization_code”
        (when SMART App Launch is supported) and “client_credentials” (when SMART Backend Services is supported).
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@228',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@378',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@384'

    input :discovery_response,
          title: 'Responds to a `/.well-known/smart-configuration` request with a discovery response',
          description: %(
            I attest that the server responds to a `/.well-known/smart-configuration` request with a discovery response
            that meets requirements described in `client-confidential-asymmetric` authentication.
          ),
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Yes',
                value: 'true'
              },
              {
                label: 'No',
                value: 'false'
              }
            ]
          }
    input :discovery_response_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    input :absolute_urls,
          title: 'Includes absolute URLs in `/.well-known/smart-configuration` request response',
          description: %(
            I attest that the server Includes absolute URLs in `/.well-known/smart-configuration` request response.
          ),
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Yes',
                value: 'true'
              },
              {
                label: 'No',
                value: 'false'
              }
            ]
          }
    input :absolute_urls_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    input :grant_types_supported,
          title: 'Requires the `grant_types_supported` when responding to a `/.well-known/smart-configuration` request',
          description: %(
            I attest that the server requires `grant_types_supported` when responding to a
            `/.well-known/smart-configuration` request.
          ),
          type: 'radio',
          default: 'false',
          options: {
            list_options: [
              {
                label: 'Yes',
                value: 'true'
              },
              {
                label: 'No',
                value: 'false'
              }
            ]
          }
    input :grant_types_supported_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert discovery_response == 'true',
             'Server did not respond with a discovery response to a `/.well-known/smart-configuration` request.'
      pass discovery_response_note if discovery_response_note.present?

      assert absolute_urls == 'true',
             'Server did not include absolute URLs in the `/.well-known/smart-configuration` request response.'
      pass absolute_urls_note if absolute_urls_note.present?

      assert grant_types_supported == 'true',
             'Server did not require `grant_types_supported` when responding to a `/.well-known/smart-configuration`
             request.'
      pass grant_types_supported_note if grant_types_supported_note.present?
    end
  end
end