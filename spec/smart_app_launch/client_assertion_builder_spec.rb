require_relative '../../lib/smart_app_launch/client_assertion_builder'

RSpec.describe SMARTAppLaunch::ClientAssertionBuilder do
  let(:client_auth_encryption_methods) { ['ES384', 'RS384'] }
  let(:iss) { 'ISS' }
  let(:sub) { 'SUB' }
  let(:aud) { 'AUD' }
  let(:jwks) { SMARTAppLaunch::JWKS.jwks }

  describe '.build' do
    it 'creates a valid JWT' do
      client_auth_encryption_methods.each do |client_auth_encryption_method|
        jwt = described_class.build(client_auth_encryption_method:, iss:, sub:, aud:)

        payload, header = JWT.decode(jwt, nil, true, algorithms: [client_auth_encryption_method], jwks:)

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
end
