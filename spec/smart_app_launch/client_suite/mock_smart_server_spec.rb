RSpec.describe SMARTAppLaunch::MockSMARTServer, :request, :runnable do
  let(:suite_id) { 'smart_client_stu2_2' }
  let(:test) { suite.children[0].children[1].children[0] } # data acccess test
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:dummy_result) { repo_create(:result, test_session_id: test_session.id) }
  let(:client_id) { 'cid' }
  let(:jwks_valid) do
    File.read(File.join(__dir__, '..', '..', '..', 'lib', 'smart_app_launch', 'smart_jwks.json'))
  end
  let(:parsed_jwks) { JWT::JWK::Set.new(JSON.parse(jwks_valid)) }
  let(:token_url) { "/custom/#{suite_id}#{SMARTAppLaunch::TOKEN_PATH}" }
  let(:access_url) { "/custom/#{suite_id}/fhir/Patient/999" }
  let(:access_response) { '{"resourceType": "Patent"}' }

  let(:header_invalid) do
    {
      typ: 'JWTX',
      alg: 'RS384',
      kid: 'b41528b6f37a9500edb8a905a595bdd7'
    }
  end
  let(:payload_invalid) do
    {
      iss: 'cid',
      sub: 'cidy',
      aud: 'https://inferno-qa.healthit.gov/suites/custom/davinci_pas_v201_client/auth/token'
    }
  end
  let(:client_assertion_sig_valid) { make_jwt(payload_invalid, header_invalid, 'RS384', parsed_jwks.keys[3]) }
  let(:client_assertion_sig_invalid) { "#{make_jwt(payload_invalid, header_invalid, 'RS384', parsed_jwks.keys[3])}bad" }
  let(:token_request_body_sig_invalid) do
    { grant_type: 'invalid',
      client_assertion_type: 'invalid',
      client_assertion: client_assertion_sig_invalid }
  end
  let(:token_request_body_sig_valid) do
    { grant_type: 'invalid',
      client_assertion_type: 'invalid',
      client_assertion: client_assertion_sig_valid }
  end

  def make_jwt(payload, header, alg, jwk)
    token = JWT::Token.new(payload:, header:)
    token.sign!(algorithm: alg, key: jwk.signing_key)
    token.jwt
  end

  def create_reg_request(body)
    repo_create(
      :request,
      direction: 'incoming',
      url: 'test',
      result: dummy_result,
      test_session_id: test_session.id,
      request_body: body,
      status: 200,
      tags: [SMARTAppLaunch::REGISTRATION_TAG, SMARTAppLaunch::UDAP_TAG]
    )
  end

  describe 'when generating token responses for SMART' do
    it 'returns 401 when the signature is bad or cannot be verified' do
      inputs = { client_id:, smart_jwk_set: jwks_valid }
      result = run(test, inputs)
      expect(result.result).to eq('wait')

      post_json(token_url, token_request_body_sig_invalid)
      expect(last_response.status).to eq(401)
      error_body = JSON.parse(last_response.body)
      expect(error_body['error']).to eq('invalid_client')
      expect(error_body['error_description']).to match(/Signature verification failed/)

      result = results_repo.find(result.id)
      expect(result.result).to eq('wait')
    end

    it 'returns 200 when the signature is correct even if header is bad' do
      inputs = { client_id:, smart_jwk_set: jwks_valid }
      result = run(test, inputs)
      expect(result.result).to eq('wait')

      post_json(token_url, token_request_body_sig_valid)
      expect(last_response.status).to eq(200)

      result = results_repo.find(result.id)
      expect(result.result).to eq('wait')
    end
  end

  describe 'when responding to access requests' do
    it 'returns 401 when the access token has expired' do
      expired_token = Base64.strict_encode64({
        client_id:,
        expiration: 1,
        nonce: SecureRandom.hex(8)
      }.to_json)

      inputs = { client_id:, smart_jwk_set: jwks_valid, echoed_fhir_response: access_response }
      result = run(test, inputs)
      expect(result.result).to eq('wait')

      header('Authorization', "Bearer #{expired_token}")
      get(access_url)
      expect(last_response.status).to eq(401)

      result = results_repo.find(result.id)
      expect(result.result).to eq('wait')
    end

    it 'returns 200 when the access token has not expired' do
      exp_timestamp = Time.now.to_i

      unexpired_token = Base64.strict_encode64({
        client_id:,
        expiration: exp_timestamp,
        nonce: SecureRandom.hex(8)
      }.to_json)

      allow(Time).to receive(:now).and_return(Time.at(exp_timestamp - 10))

      inputs = { client_id:, smart_jwk_set: jwks_valid, echoed_fhir_response: access_response }
      result = run(test, inputs)
      expect(result.result).to eq('wait')

      header('Authorization', "Bearer #{unexpired_token}")
      get(access_url)
      expect(last_response.status).to eq(200)

      result = results_repo.find(result.id)
      expect(result.result).to eq('wait')
    end

    it 'returns 200 when the decoded access token has no expiration' do
      token_no_exp = Base64.strict_encode64({
        client_id:,
        nonce: SecureRandom.hex(8)
      }.to_json)

      inputs = { client_id:, smart_jwk_set: jwks_valid, echoed_fhir_response: access_response }
      result = run(test, inputs)
      expect(result.result).to eq('wait')

      header('Authorization', "Bearer #{token_no_exp}")
      get(access_url)
      expect(last_response.status).to eq(200)

      result = results_repo.find(result.id)
      expect(result.result).to eq('wait')
    end
  end
end
