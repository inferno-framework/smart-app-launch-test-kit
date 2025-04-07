require_relative '../urls'
require_relative '../endpoints/mock_smart_server'

module SMARTAppLaunch
  class SMARTClientAccessInteraction < Inferno::Test
    include URLs

    id :smart_client_access_interaction
    title 'Perform SMART-secured Access'
    description %(
      During this test, Inferno will wait for the client to access data
      using a SMART token obtained during earlier tests.
    )
    input :client_id,
          title: 'Client Id',
          type: 'text',
          locked: true,
          description: %(
            The registered Client Id for use in obtaining access tokens.
            Create a new session if you need to change this value.
          )
    input :smart_jwk_set,
          title: 'JSON Web Key Set (JWKS)',
          type: 'textarea',
          optional: true,
          locked: true,
          description: %(
            The SMART client's JSON Web Key Set in the form of either a publicly accessible url
            containing the JWKS, or the raw JWKS JSON. Must include the key(s) Inferno will need to
            verify signatures on token requests made by the client.
            Create a new session if you need to change this value.
          )
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

    run do
      wait(
        identifier: client_id,
        message: %(
            **Access**

            Use the registered client id (#{client_id}) to obtain an access
            token using SMART Backend Services
            and use that token to access a FHIR endpoint under the simulated server's base URL

            `#{client_fhir_base_url}`

            Inferno will echo the response provided in the **FHIR Response to Echo** input.

            [Click here](#{client_resume_pass_url}?token=#{client_id}) once you performed
            the access.
          )
      )
    end
  end
end
