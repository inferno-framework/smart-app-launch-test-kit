require_relative 'token_exchange_test'
require_relative 'token_refresh_body_test'
require_relative 'well_known_endpoint_test'
require_relative 'standalone_launch_group'

module SMARTAppLaunch
  class SMARTTokenIntrospectionRequestGroup < Inferno::TestGroup
    title 'Issue Token Introspection Request'
    run_as_group

    id :smart_token_introspection_request_group
    description %(
      This group of tests executes the token introspection requests and ensures the correct HTTP response is returned
      but does not validate the contents of the token introspection response.

      If Inferno cannot reasonably be configured to be authorized to access the token introspection endpoint, these tests
      can be skipped.  Instead, an out-of-band token introspection request must be completed and the response body
      manually provided as input for the Validate Introspection Response test group.
      )

    input_instructions %(
      If the Request New Access Token group was executed, the access token input will auto-populate with that token.
      Otherwise an active access token needs to be obtained out-of-band and input.

      Per [RFC-7662](https://datatracker.ietf.org/doc/html/rfc7662#section-2), "the definition of an active token is
      currently dependent upon the authorization server, but this is commonly a token that has been issued by this
      authorization server, is not expired, has not been revoked, and is valid for use at the protected resource making
      the introspection call."

      If the introspection endpoint is protected, testers must enter their own HTTP Authorization header for the introspection request.  See
      [RFC 7616 The 'Basic' HTTP Authentication Scheme](https://datatracker.ietf.org/doc/html/rfc7617) for the most common
      approach that uses client credentials.  Testers may also provide any additional parameters needed for their authorization
      server to complete the introspection request.

      **Note:** For both the Authorization header and request parameters, user-input
      values will be sent exactly as entered and therefore the tester must URI-encode any appropriate values.
    )

    input :well_known_introspection_url,
          title: 'Token Introspection Endpoint URL',
          description: 'The complete URL of the token introspection endpoint.'

    input :custom_authorization_header,
          title: 'Custom HTTP Headers for Introspection Request',
          type: 'textarea',
          optional: true,
          description: %(
            Add custom headers for the introspection request by adding each header's name and value with a new line
            between each header.
            Ex:
              <Header 1 Name>: <Value 1>
              <Header 2 Name>: <Value 2>
            )

    input :optional_introspection_request_params,
          title: 'Additional Introspection Request Parameters',
          type: 'textarea',
          optional: true,
          description: %(
            Any additional parameters to append to the request body, separated by &. Example: 'param1=abc&param2=def'
          )

    test do
      title 'Token introspection endpoint returns a response when provided an active token'
      description %(
      This test will execute a token introspection request for an active token and ensure a 200 status and valid JSON
      body are returned in the response.
      )

      input :standalone_access_token,
            title: 'Access Token',
            description: 'The access token to be introspected. MUST be active.'

      output :active_token_introspection_response_body

      run do
        # If this is being chained from an earlier test, it might be blank if not present in the well-known endpoint
        skip_if well_known_introspection_url.nil?, 'No introspection URL present in SMART well-known endpoint.'

        headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/x-www-form-urlencoded' }
        body = "token=#{standalone_access_token}"

        if custom_authorization_header.present?
          custom_headers = custom_authorization_header.split("\n")
          custom_headers.each do |custom_header|
            parsed_header = custom_header.split(':', 2)
            assert parsed_header.length == 2,
                   'Incorrect custom HTTP header format input, expected: "<header name>: <header value>"'
            headers[parsed_header[0]] = parsed_header[1].strip
          end
        end

        body += "&#{optional_introspection_request_params}" if optional_introspection_request_params.present?

        post(well_known_introspection_url, body:, headers:)

        assert_response_status(200)
        output active_token_introspection_response_body: request.response_body
      end
    end

    test do
      title 'Token introspection endpoint returns a response when provided an invalid token'
      description %(
        This test will execute a token introspection request for an invalid token and ensure a 200 status and valid JSON
        body are returned in response.
      )

      output :invalid_token_introspection_response_body
      run do
        # If this is being chained from an earlier test, it might be blank if not present in the well-known endpoint
        skip_if well_known_introspection_url.nil?, 'No introspection URL present in SMART well-known endpoint.'

        headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/x-www-form-urlencoded' }
        body = 'token=invalid_token_value'
        post(well_known_introspection_url, body:, headers:)

        assert_response_status(200)
        output invalid_token_introspection_response_body: request.response_body
      end
    end
  end
end
