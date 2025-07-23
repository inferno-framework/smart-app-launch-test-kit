module SMARTAppLaunch
  class SsoOpenIdConnectCapabilityAttestationTest < Inferno::Test
    title 'Follows guidelines for SMART sso-openid-connect compatibility'
    id :sso_openid_connect_capability
    description %(
      Servers wishing to be compatible with the SMART's sso-openid-connect capability do the following:
      - Support the Authorization Code Flow, with the request parameters as defined in SMART App Launch
      - Support the inclusion of SMART's `fhirUser` claim within the `id_token` issued for any requests that grant the
        `openid` and `fhirUser` scopes
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@205',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@209'

    input :auth_code_flow_support,
          title: 'Supports the Authorization Code Flow',
          description: %(
            I attest that the server supports the Authorization Code Flow, with the request parameters as defined in
            SMART App Launch.
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
    input :auth_code_flow_support_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    input :fhir_user_inclusion,
          title: 'Supports the inclusion of SMART\'s `fhirUser`',
          description: %(
            I attest that the server supports the inclusion of SMART's `fhirUser` claim within the `id_token` issued
            for any requests that grant the `openid` and `fhirUser` scopes.
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
    input :fhir_user_inclusion_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert auth_code_flow_support == 'true',
             'Server did not support the Authorization Code Flow.'
      pass auth_code_flow_support_note if auth_code_flow_support_note.present?

      assert fhir_user_inclusion == 'true',
             'Server did not support the inclusion of SMART\'s `fhirUser`.'
      pass fhir_user_inclusion_note if fhir_user_inclusion_note.present?
    end
  end
end