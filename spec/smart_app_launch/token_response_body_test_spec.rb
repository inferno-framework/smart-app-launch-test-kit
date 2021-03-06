require_relative '../../lib/smart_app_launch/token_exchange_test'
require_relative '../request_helper'

RSpec.describe SMARTAppLaunch::TokenResponseBodyTest do
  include Rack::Test::Methods
  include RequestHelpers

  let(:test) { Inferno::Repositories::Tests.new.find('smart_token_response_body') }
  let(:valid_body) do
    {
      access_token: 'ACCESS_TOKEN',
      token_type: 'bearer',
      expires_in: 3600,
      scope: 'patient/*.*'
    }
  end
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart') }

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(
        test_session_id: test_session.id,
        name: name,
        value: value,
        type: runnable.config.input_type(name)
      )
    end
    Inferno::TestRunner.new(test_session: test_session, test_run: test_run).run(runnable)
  end

  def create_token_request(body: nil, status: 200, headers: nil)
    headers ||= [
      {
        type: 'response',
        name: 'Cache-Control',
        value: 'no-store'
      },
      {
        type: 'response',
        name: 'Pragma',
        value: 'no-cache'
      }
    ]
    repo_create(
      :request,
      direction: 'outgoing',
      name: 'token',
      url: 'http://example.com/token',
      test_session_id: test_session.id,
      response_body: body.is_a?(Hash) ? body.to_json : body,
      status: status,
      headers: headers
    )
  end

  it 'passes if the body contains the required fields' do
    create_token_request(body: valid_body)

    result = run(test, requested_scopes: 'patient/*.*')

    expect(result.result).to eq('pass')
  end

  it 'skips if the token request was not successful' do
    create_token_request(body: { access_token: 'ACCESS_TOKEN', token_type: 'bearer' }, status: 500)

    result = run(test)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/was unsuccessful/)
  end

  it 'fails if the body is not valid json' do
    create_token_request(body: '[[')

    result = run(test)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Invalid JSON/)
  end

  it 'fails if the body does not contain a required field' do
    valid_body.each_key do |field|
      bad_body = valid_body.reject { |key, _| key == field }
      create_token_request(body: bad_body)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/`#{field}`/)
    end
  end

  it 'fails is the fields are the wrong types' do
    described_class::STRING_FIELDS.each do |field|
      body = valid_body.merge(field => 123)
      create_token_request(body: body)

      result = run(test, requested_scopes: 'patient/*.*')

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/String/)
    end

    described_class::NUMERIC_FIELDS.each do |field|
      body = valid_body.merge(field => '123')
      create_token_request(body: body)

      result = run(test, requested_scopes: 'patient/*.*')

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/Numeric/)
    end
  end

  it 'persists outputs' do
    inputs = {
      access_token: 'ACCESS_TOKEN',
      id_token: 'ID_TOKEN',
      refresh_token: 'REFRESH_TOKEN',
      expires_in: 3600,
      patient: 'PATIENT',
      encounter: 'ENCOUNTER',
      scope: 'SCOPE',
      token_type: 'BEARER',
      intent: 'INTENT'
    }
    expected_outputs = {
      id_token: inputs[:id_token],
      refresh_token: inputs[:refresh_token],
      access_token: inputs[:access_token],
      expires_in: inputs[:expires_in],
      patient_id: inputs[:patient],
      encounter_id: inputs[:encounter],
      received_scopes: inputs[:scope],
      intent: inputs[:intent]
    }
    create_token_request(body: inputs)

    result = run(test, requested_scopes: 'SCOPE')

    expect(result.result).to eq('pass')

    expected_outputs.each do |name, value|
      persisted_data = session_data_repo.load(test_session_id: test_session.id, name: name)

      expect(persisted_data).to eq(value.to_s)
    end
  end
end
