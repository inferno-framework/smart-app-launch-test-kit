require_relative '../../lib/smart_app_launch/token_exchange_stu2_test'
require_relative '../request_helper'

RSpec.describe SMARTAppLaunch::TokenExchangeSTU2Test do
  include Rack::Test::Methods
  include RequestHelpers

  let(:test) { Inferno::Repositories::Tests.new.find('smart_token_exchange_stu2') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:suite_id) { 'smart'}
  let(:url) { 'http://example.com/fhir' }
  let(:token_url) { 'http://example.com/token' }
  let(:client_id) { 'CLIENT_ID' }
  let(:client_auth_encryption_method) { 'ES384' }
  let(:inputs) do
    {
      code: 'CODE',
      smart_token_url: token_url,
      client_auth_type: 'confidential_asymmetric',
      client_auth_encryption_method:,
      auth_info: Inferno::DSL::AuthInfo.new(
        client_id:,
        pkce_support: 'disabled'
      )
    }
  end

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      type = runnable.config.input_type(name)
      type = 'text' if type == 'radio'
      session_data_repo.save(
        test_session_id: test_session.id,
        name: name,
        value: value,
        type: type.presence
      )
    end
    Inferno::TestRunner.new(test_session: test_session, test_run: test_run).run(runnable)
  end

  def create_redirect_request(url)
    repo_create(
      :request,
      direction: 'incoming',
      name: 'redirect',
      url: url,
      test_session_id: test_session.id
    )
  end

  context 'with an asymmetric confidential client' do
    it 'passes if the token response has a 200 status' do
      create_redirect_request('http://example.com/redirect?code=CODE')
      stub_request(:post, token_url)
        .with(
          body: hash_including(
            {
              grant_type: 'authorization_code',
              code: 'CODE',
              redirect_uri: "#{Inferno::Application['base_url']}/custom/smart/redirect",
              client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer'
            }
          )
        )
        .to_return(status: 200, body: {}.to_json)

      result = run(test, inputs)

      expect(result.result).to eq('pass')
    end
  end
end
