module SMARTAppLaunch
  class SsoOpenIdConnectCapabilityAttestationTest < Inferno::Test
    title 'Complies with requirements for SMART\'s sso-openid-connect capability'
    id :sso_openid_connect_capability
    description %(
      The server complies with requirements for SMART's sso-openid-connect capability:
      - Support the Authorization Code Flow, with the request parameters as defined in SMART App Launch
      - Support the inclusion of SMART's `fhirUser` claim within the `id_token` issued for any requests that grant the
        `openid` and `fhirUser` scopes
    )
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@205',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@209'

    input :sso_openid_connect_capability_correct,
          title: 'Complies with requirements for SMART\'s sso-openid-connect capability',
          description: %(
            I attest that the server complies with requirements for SMART's sso-openid-connect capability:
            - Support the Authorization Code Flow, with the request parameters as defined in SMART App Launch
            - Support the inclusion of SMART's `fhirUser` claim within the `id_token` issued for any requests that grant
              the `openid` and `fhirUser` scopes
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
    input :sso_openid_connect_capability_note,
          title: 'Notes, if applicable:',
          type: 'textarea',
          optional: true

    run do
      assert sso_openid_connect_capability_correct == 'true',
             'Server does not comply with requirements for SMART\'s sso-openid-connect capability.'
      pass sso_openid_connect_capability_note if sso_openid_connect_capability_note.present?
    end
  end
end