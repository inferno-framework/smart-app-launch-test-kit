require_relative 'token_exchange_stu2_test'

module SMARTAppLaunch
  class TokenExchangeSTU22Test < TokenExchangeSTU2Test
    id :smart_token_exchange_stu2_2
    verifies_requirements 'hl7.fhir.uv.smart-app-launch_2.2.0@62',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@63',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@64',
                          'hl7.fhir.uv.smart-app-launch_2.2.0@236'

    def add_credentials_to_request(oauth2_params, oauth2_headers)
      if client_auth_type == 'confidential_symmetric'
        assert client_secret.present?,
               'A client secret must be provided when using confidential symmetric client authentication.'

        client_credentials = "#{client_id}:#{client_secret}"
        oauth2_headers['Authorization'] = "Basic #{Base64.strict_encode64(client_credentials)}"
      elsif client_auth_type == 'public'
        oauth2_params[:client_id] = client_id
        oauth2_headers['Origin'] = Inferno::Application['inferno_host']
      else
        oauth2_params.merge!(
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          client_assertion: ClientAssertionBuilder.build(
            iss: client_id,
            sub: client_id,
            aud: smart_token_url,
            client_auth_encryption_method:
          )
        )
      end
    end
  end
end
