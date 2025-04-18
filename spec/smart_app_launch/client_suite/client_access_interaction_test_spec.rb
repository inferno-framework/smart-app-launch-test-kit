RSpec.describe SMARTAppLaunch::SMARTClientAccessInteraction, :request do # rubocop:disable RSpec/SpecFilePathFormat
  let(:suite_id) { 'smart_client_stu2_2' }

  describe 'during the acess wait test' do
    let(:static_uuid) { 'f015a331-3a86-4566-b72f-b5b85902cdca' }
    let(:test) { described_class }
    let(:results_repo) { Inferno::Repositories::Results.new }
    let(:requests_repo) { Inferno::Repositories::Requests.new }
    let(:patient_read_url) { "/custom/#{suite_id}/fhir/Patient/999" }
    let(:patient_read_response) { '{ "resourceType": "Patient" }' }
    let(:token_url) { "/custom/#{suite_id}#{SMARTAppLaunch::TOKEN_PATH}" }
    let(:jwks_valid) do
      File.read(File.join(__dir__, '..', '..', '..', 'lib', 'smart_app_launch', 'smart_jwks.json'))
    end
    let(:parsed_jwks) { JWT::JWK::Set.new(JSON.parse(jwks_valid)) }
    let(:jwks_url_valid) { 'https://inferno.healthit.gov/suites/custom/smart_stu2/.well-known/jwks.json' }
    let(:token_endpoint) { 'https://inferno.healthit.gov/suites/custom/smart_client_stu2_2/auth/token' }
    let(:client_id) { 'test_client' }
    let(:header_valid) do
      {
        typ: 'JWT',
        alg: 'RS384',
        kid: 'b41528b6f37a9500edb8a905a595bdd7'
      }
    end
    let(:payload_valid) do
      {
        iss: client_id,
        sub: client_id,
        aud: token_endpoint,
        exp: 1741398050,
        jti: 'random-non-reusable-jwt-id-123'
      }
    end
    let(:client_assertion_valid) { make_jwt(payload_valid, header_valid, 'RS384', parsed_jwks.keys[3]) }
    let(:token_request_body_valid) do
      { grant_type: 'client_credentials',
        scope: 'system/*.rs',
        client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
        client_assertion: client_assertion_valid }
    end

    def make_jwt(payload, header, alg, jwk)
      token = JWT::Token.new(payload:, header:)
      token.sign!(algorithm: alg, key: jwk.signing_key)
      token.jwt
    end

    describe 'it responds to token requests' do
      describe 'it succeeds' do
        it 'when using a provided jwks url' do
          stub_request(:get, jwks_url_valid)
            .to_return(status: 200, body: jwks_valid)

          inputs = { client_id:, smart_jwk_set: jwks_url_valid }
          result = run(test, inputs)
          expect(result.result).to eq('wait')

          post(token_url, URI.encode_www_form(token_request_body_valid))

          expect(last_response.status).to be(200)
        end

        it 'when using provided raw jwks json' do
          inputs = { client_id:, smart_jwk_set: jwks_valid }
          result = run(test, inputs)
          expect(result.result).to eq('wait')

          post(token_url, URI.encode_www_form(token_request_body_valid))

          expect(last_response.status).to be(200)
        end
      end
    end

    describe 'it responds to access requests' do
      it 'returns the tester-provided response' do
        inputs = { client_id:, smart_jwk_set: jwks_valid, echoed_fhir_response: patient_read_response }
        result = run(test, inputs)
        expect(result.result).to eq('wait')

        header('Authorization', "Bearer #{Base64.urlsafe_encode64({ client_id: client_id }.to_json, padding: false)}")
        get(patient_read_url)

        expect(last_response.status).to be(200)
        expect(last_response.body).to eq(patient_read_response)
      end

      it 'returns an operaion outcome when no tester-provided response' do
        inputs = { client_id:, smart_jwk_set: jwks_valid }
        result = run(test, inputs)
        expect(result.result).to eq('wait')

        header('Authorization', "Bearer #{Base64.urlsafe_encode64({ client_id: client_id }.to_json, padding: false)}")
        get(patient_read_url)

        expect(last_response.status).to be(400)
        expect(FHIR.from_contents(last_response.body)).to be_a(FHIR::OperationOutcome)
      end
    end
  end
end
