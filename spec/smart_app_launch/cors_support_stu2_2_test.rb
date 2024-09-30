require_relative '../../lib/smart_app_launch/token_exchange_test'
require_relative '../request_helper'

RSpec.describe SMARTAppLaunch::TokenResponseBodyTest do
  include Rack::Test::Methods
  include RequestHelpers

  let(:test) { Inferno::Repositories::Tests.new.find('cors_support_stu2_2') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart') }

  let(:valid_body) do
    {
      access_token: 'ACCESS_TOKEN',
      token_type: 'bearer',
      expires_in: 3600,
      scope: 'patient/*.*'
    }
  end

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(
        test_session_id: test_session.id,
        name:,
        value:,
        type: runnable.config.input_type(name)
      )
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable)
  end

  def cors_header_origin(value)
    [
      {
        type: 'response',
        name: 'Access-Control-Allow-Origin',
        value:
      }
    ]
  end

  def create_cors_request(body: nil, status: 200, headers: nil)
    repo_create(
      :request,
      direction: 'outgoing',
      name: 'cors_request',
      url: 'http://example.com/token',
      test_session_id: test_session.id,
      response_body: body.is_a?(Hash) ? body.to_json : body,
      status:,
      headers:
    )
  end

  it 'passes if the request contains a valid cors header with Inferno Origin' do
    create_cors_request(body: valid_body, headers: cors_header_origin(Inferno::Application['inferno_host']))

    result = run(test)

    expect(result.result).to eq('pass')
  end

  it 'passes if the request contains a valid cors header wit *' do
    create_cors_request(body: valid_body, headers: cors_header_origin('*'))

    result = run(test)

    expect(result.result).to eq('pass')
  end

  it 'skips if the previous request was not made' do
    result = run(test)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/was not made/)
  end

  it 'skips if the previous request was not successful' do
    create_cors_request(body: { access_token: 'ACCESS_TOKEN', token_type: 'bearer' }, status: 500)

    result = run(test)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/was unsuccessful/)
  end

  it 'fails if the CORS header is not included in response' do
    create_cors_request(body: valid_body, headers: [])

    result = run(test)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Request must have `Access-Control-Allow-Origin`/)
  end

  it 'fails if the CORS header is not valid' do
    create_cors_request(body: valid_body, headers: cors_header_origin('incorrect_origin'))

    result = run(test)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Request must have `Access-Control-Allow-Origin`/)
  end
end
