require_relative 'token_payload_validation'

module SMARTAppLaunch
  class TokenRefreshTest < Inferno::Test
    include TokenPayloadValidation

    id :smart_token_refresh
    title 'Server successfully refreshes the access token when optional scope parameter omitted'
    description %(
      Server successfully exchanges refresh token at OAuth token endpoint
      without providing scope in the body of the request.

      Although not required in the token refresh portion of the SMART App
      Launch Guide, the token refresh response should include the HTTP
      Cache-Control response header field with a value of no-store, as well as
      the Pragma response header field with a value of no-cache to be
      consistent with the requirements of the inital access token exchange.
    )
    input :smart_token_url, :refresh_token, :client_id, :received_scopes
    input :client_secret, optional: true
    output :smart_credentials, :token_retrieval_time
    makes_request :token_refresh

    run do
      skip_if refresh_token.blank?

      oauth2_params = {
        'grant_type' => 'refresh_token',
        'refresh_token' => refresh_token
      }
      oauth2_headers = { 'Content-Type' => 'application/x-www-form-urlencoded' }

      oauth2_params['scope'] = received_scopes if config.options[:include_scopes]

      if client_secret.present?
        credentials = Base64.strict_encode64("#{client_id}:#{client_secret}")
        oauth2_headers['Authorization'] = "Basic #{credentials}"
      else
        oauth2_params['client_id'] = client_id
      end

      post(smart_token_url, body: oauth2_params, name: :token_refresh, headers: oauth2_headers)

      assert_response_status(200)
      assert_valid_json(request.response_body)

      output token_retrieval_time: Time.now.iso8601

      token_response_body = JSON.parse(request.response_body)
      output smart_credentials: {
               refresh_token: token_response_body['refresh_token'],
               access_token: token_response_body['access_token'],
               expires_in: token_response_body['expires_in'],
               client_id: client_id,
               client_secret: client_secret,
               token_retrieval_time: token_retrieval_time,
               token_url: smart_token_url
             }.to_json
    end
  end
end
