require_relative '../../lib/smart_app_launch/token_response_headers_test_stu2_2'
require_relative '../request_helper'

RSpec.describe SMARTAppLaunch::TokenResponseHeadersTestSTU22 do
  include Rack::Test::Methods
  include RequestHelpers

  let(:test) { Inferno::Repositories::Tests.new.find('smart_token_response_headers_stu2_2') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_stu2_2') }

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
      },
      {
        type: 'response',
        name: 'Access-Control-Allow-Origin',
        value: Inferno::Application['base_url']
      }
    ]
    repo_create(
      :request,
      direction: 'outgoing',
      name: 'token',
      url: 'http://example.com/token',
      test_session_id: test_session.id,
      response_body: body.is_a?(Hash) ? body.to_json : body,
      status:,
      headers:
    )
  end

  it 'passes if the response contains headers with the required values' do
    create_token_request

    result = run(test)
    expect(result.result).to eq('pass')
  end

  it 'skips if the token request was not successful' do
    create_token_request(status: 500)

    result = run(test)

    expect(result.result).to eq('skip')
    expect(result.result_message).to match(/was unsuccessful/)
  end

  it 'fails if the required headers are not present' do
    create_token_request(headers: [])

    result = run(test)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Token response must have/)
  end

  it 'fails if the Cache-Control header does not contain no-store' do
    create_token_request(
      headers: [
        {
          type: 'response',
          name: 'Cache-Control',
          value: 'abc'
        },
        {
          type: 'response',
          name: 'Pragma',
          value: 'no-cache'
        },
        {
          type: 'response',
          name: 'Access-Control-Allow-Origin',
          value: Inferno::Application['base_url']
        }
      ]
    )

    result = run(test)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/`Cache-Control`/)
  end

  it 'fails if the Pragma header does not contain no-cache' do
    create_token_request(
      headers: [
        {
          type: 'response',
          name: 'Cache-Control',
          value: 'no-store'
        },
        {
          type: 'response',
          name: 'Pragma',
          value: 'abc'
        },
        {
          type: 'response',
          name: 'Access-Control-Allow-Origin',
          value: Inferno::Application['base_url']
        }
      ]
    )

    result = run(test)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/`Pragma`/)
  end

  it 'fails if no CORs header received' do
    create_token_request(
      headers: [
        {
          type: 'response',
          name: 'Cache-Control',
          value: 'no-store'
        },
        {
          type: 'response',
          name: 'Pragma',
          value: 'abc'
        }
      ]
    )

    result = run(test)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(
      'Token response must have `Access-Control-Allow-Origin` header containing'
    )
  end

  it 'fails if the CORs header does not equal Inferno origin' do
    create_token_request(
      headers: [
        {
          type: 'response',
          name: 'Cache-Control',
          value: 'no-store'
        },
        {
          type: 'response',
          name: 'Pragma',
          value: 'abc'
        },
        {
          type: 'response',
          name: 'Access-Control-Allow-Origin',
          value: 'https://incorrect-origin.com'
        }
      ]
    )

    result = run(test)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/`Access-Control-Allow-Origin`/)
  end
end
