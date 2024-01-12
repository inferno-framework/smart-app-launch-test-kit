require_relative '../../lib/smart_app_launch/client_assertion_builder'
require_relative '../../lib/smart_app_launch/jwks'

RSpec.describe SMARTAppLaunch::ClientAssertionBuilder do
  let(:client_auth_encryption_methods) { ['ES384', 'RS384'] }
  let(:iss) { 'ISS' }
  let(:sub) { 'SUB' }
  let(:aud) { 'AUD' }
  let(:jwks) { SMARTAppLaunch::JWKS.jwks }

  def build_and_decode_jwt(encryption_method, kid)
    jwt = described_class.build(client_auth_encryption_method: encryption_method, iss:, sub:, aud:, kid: kid)
    return JWT.decode(jwt, kid, true, algorithms: [encryption_method], jwks:)
  end

  describe '.build' do
    context 'with unspecified key id' do
      it 'creates a valid JWT' do
        client_auth_encryption_methods.each do |client_auth_encryption_method|
          payload, header = build_and_decode_jwt(client_auth_encryption_method, nil)

          expect(header['alg']).to eq(client_auth_encryption_method)
          expect(header['typ']).to eq('JWT')
          expect(payload['iss']).to eq(iss)
          expect(payload['sub']).to eq(sub)
          expect(payload['aud']).to eq(aud)
          expect(payload['exp']).to be_present
          expect(payload['jti']).to be_present
        end
      end
    end

    context 'with specified key id' do
      it 'creates a valid JWT with correct algorithm and kid' do
        encryption_method = 'ES384'
        kid = '4b49a739d1eb115b3225f4cf9beb6d1b'
        payload, header = build_and_decode_jwt(encryption_method, kid)

        expect(header['alg']).to eq(encryption_method)
        expect(header['typ']).to eq('JWT')
        expect(header['kid']).to eq(kid)
        expect(payload['iss']).to eq(iss)
        expect(payload['sub']).to eq(sub)
        expect(payload['aud']).to eq(aud)
        expect(payload['exp']).to be_present
        expect(payload['jti']).to be_present
      end

      it 'throws exception when key id not found for algorithm' do
        encryption_method = 'RS384'
        kid = '4b49a739d1eb115b3225f4cf9beb6d1b'

        expect {
          build_and_decode_jwt(encryption_method, kid)
        }.to raise_error(RuntimeError)
      end
    end
  end
end
