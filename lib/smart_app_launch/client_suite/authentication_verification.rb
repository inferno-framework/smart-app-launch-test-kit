module SMARTAppLaunch
  module AuthenticationVerification
    def check_authentication(request, request_params, request_num, jti_list)
      case SMARTClientOptions.smart_authentication_approach(suite_options)
      when CONFIDENTIAL_ASYMMETRIC_TAG
        check_client_assertion(request_params['client_assertion'], request_num, jti_list)
      when CONFIDENTIAL_SYMMETRIC_TAG
        check_authorization_header(request, request_num)
      end
    end

    def check_authorization_header(request, request_num)
      # todo
    end

    def check_client_assertion(assertion, request_num, jti_list)
      decoded_token =
        begin
          JWT::EncodedToken.new(assertion)
        rescue StandardError => e
          add_message('error', "Token request #{request_num} contained an invalid client assertion jwt: #{e}")
          nil
        end

      return unless decoded_token.present?

      check_jwt_header(decoded_token.header, request_num)
      check_jwt_payload(decoded_token.payload, request_num, jti_list)
      check_jwt_signature(decoded_token, request_num)
    end

    def check_jwt_header(header, request_num)
      return unless header['typ'] != 'JWT'

      add_message('error', "client assertion jwt on token request #{request_num} has an incorrect `typ` header: " \
                           "expected 'JWT', got '#{header['typ']}'")
    end

    def check_jwt_payload(claims, request_num, jti_list)
      if claims['iss'] != client_id
        add_message('error', "client assertion jwt on token request #{request_num} has an incorrect `iss` claim: " \
                             "expected '#{client_id}', got '#{claims['iss']}'")
      end

      if claims['sub'] != client_id
        add_message('error', "client assertion jwt on token request #{request_num} has an incorrect `sub` claim: " \
                             "expected '#{client_id}', got '#{claims['sub']}'")
      end

      if claims['aud'] != client_token_url
        add_message('error', "client assertion jwt on token request #{request_num} has an incorrect `aud` claim: " \
                             "expected '#{client_token_url}', got '#{claims['aud']}'")
      end

      if claims['exp'].blank?
        add_message('error', "client assertion jwt on token request #{request_num} is missing the `exp` claim.")
      end

      if claims['jti'].blank?
        add_message('error', "client assertion jwt on token request #{request_num} is missing the `jti` claim.")
      elsif jti_list.include?(claims['jti'])
        add_message('error', "client assertion jwt on token request #{request_num} has a `jti` claim that was " \
                             "previouly used: '#{claims['jti']}'.")
      else
        jti_list << claims['jti']
      end
    end

    def check_jwt_signature(encoded_token, request_num)
      error = MockSMARTServer.smart_assertion_signature_verification(encoded_token, smart_jwk_set)

      return unless error.present?

      add_message('error', "Signature validation failed on token request #{request_num}: #{error}")
    end
  end
end