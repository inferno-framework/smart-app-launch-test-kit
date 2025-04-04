require_relative '../tags'
require_relative '../endpoints/mock_smart_server'

module SMARTAppLaunch
  class SMARTClientTokenUseVerification < Inferno::Test

    id :smart_client_token_use_verification
    title 'Verify SMART Token Use'
    description %(
        Check that a SMART token returned to the client was used for request
        authentication.
      )

    input :smart_tokens,
          optional: true # verified in the test to return a more specific error message
    input :smart_jwk_set,
          optional: false,
          locked: true

    def access_request_tags
      return config.options[:access_request_tags] if config.options[:access_request_tags].present?

      [ACCESS_TAG]
    end

    run do
      omit_if smart_jwk_set.blank?, # for re-use: mark the smart_jwk_set input as optional when importing to enable
        'SMART Authentication not demonstrated as a part of this test session.'

      access_requests = access_request_tags.map do |access_request_tag|
        load_tagged_requests(access_request_tag).reject { |access| access.status == 401 }
      end.flatten
      obtained_tokens = smart_tokens&.split("\n")

      skip_if obtained_tokens.blank?, 'No token requests made.'
      skip_if access_requests.blank?, 'No successful access requests made.'

      used_tokens = access_requests.map do |access_request|
        access_request.request_headers.find do |header|
          header.name.downcase == 'authorization'
        end&.value&.delete_prefix('Bearer ')
      end.compact

      assert (used_tokens & obtained_tokens).present?, 'Returned tokens never used in any requests.'
    end
  end
end
