module SMARTAppLaunch
  class WellKnownSmartConfigurationRequestAttestationTest < Inferno::Test
    title 'Complies with requirements for requests to the `/.well-known/smart-configuration` endpoint'
    id :well_known_smart_config_request
    description %(
      The server complies with requirements for requests to the `/.well-known/smart-configuration` endpoint:
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

    input :well_known_smart_config_request_correct,
          title: 'Complies with requirements for requests to the `/.well-known/smart-configuration` endpoint',
          description: %(
            I attest that the server complies with requirements for requests to the `/.well-known/smart-configuration`
            endpoint:
            - Responds with a discovery response that meets requirements described in `client-confidential-asymmetric`
              authentication
            - Includes absolute URLs in the response document from `/.well-known/smart-configuration` requests
            - Requires `grant_types_supported` and that it contains the Array of grant types supported at the token
              endpoint when responding to a `/.well-known/smart-configuration` request. The options are
              “authorization_code” (when SMART App Launch is supported) and “client_credentials” (when SMART Backend
              Services is supported).
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
    input :well_known_smart_config_request_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert well_known_smart_config_request_correct == 'true',
             'Server does not comply with requirements for requests to the `/.well-known/smart-configuration` endpoint.'
      pass well_known_smart_config_request_note if well_known_smart_config_request_note.present?
    end
  end
end