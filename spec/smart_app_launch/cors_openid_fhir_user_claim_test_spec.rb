require_relative '../../lib/smart_app_launch/cors_openid_fhir_user_claim_test'

RSpec.describe SMARTAppLaunch::CORSOpenIDFHIRUserClaimTest do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('smart_stu2_2') }
  let(:test) { Inferno::Repositories::Tests.new.find('smart_cors_openid_fhir_user_claim') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_stu2_2') }

  let(:client_id) { 'CLIENT_ID' }
  let(:smart_credentials) do
    {
      access_token: 'ACCESS_TOKEN',
      refresh_token: 'REFRESH_TOKEN',
      expires_in: 3600,
      client_id:,
      token_retrieval_time: Time.now.iso8601,
      token_url: 'http://example.com/token'
    }.to_json
  end
  let(:url) { 'http://example.com/fhir' }
  let(:id_token_fhir_user) { "#{url}/Patient/123" }

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

  def cors_header(value)
    {
      'Access-Control-Allow-Origin' => value
    }
  end

  it 'passes when the fhir user can be retrieved with valid origin cors header' do
    user_request =
      stub_request(:get, id_token_fhir_user)
        .to_return(status: 200, body: FHIR::Patient.new(id: '123').to_json,
                   headers: cors_header(Inferno::Application['inferno_host']))

    result = run(
      test,
      url:,
      smart_credentials:,
      id_token_fhir_user:
    )

    expect(result.result).to eq('pass')
    expect(user_request).to have_been_made
  end

  it 'passes when the fhir user can be retrieved with valid wildcard cors header' do
    user_request =
      stub_request(:get, id_token_fhir_user)
        .to_return(status: 200, body: FHIR::Patient.new(id: '123').to_json,
                   headers: cors_header('*'))
    result = run(
      test,
      url:,
      smart_credentials:,
      id_token_fhir_user:
    )

    expect(result.result).to eq('pass')
    expect(user_request).to have_been_made
  end

  it 'fails when a non-200 response is received' do
    user_request =
      stub_request(:get, id_token_fhir_user)
        .to_return(status: 500, body: FHIR::Patient.new(id: '123').to_json,
                   headers: cors_header(Inferno::Application['inferno_host']))

    result = run(
      test,
      url:,
      smart_credentials:,
      id_token_fhir_user:
    )

    expect(result.result).to eq('fail')
    expect(user_request).to have_been_made
    expect(result.result_message).to match(/Unexpected response status/)
  end

  it 'fails when a response with no cors header is received' do
    user_request =
      stub_request(:get, id_token_fhir_user)
        .to_return(status: 200, body: FHIR::Patient.new(id: '123').to_json)

    result = run(
      test,
      url:,
      smart_credentials:,
      id_token_fhir_user:
    )

    expect(result.result).to eq('fail')
    expect(user_request).to have_been_made
    expect(result.result_message).to match('No `Access-Control-Allow-Origin` header received')
  end

  it 'fails when a response with incorrect cors header is received' do
    user_request =
      stub_request(:get, id_token_fhir_user)
        .to_return(status: 200, body: FHIR::Patient.new(id: '123').to_json,
                   headers: cors_header('https://incorrect-origin.com'))

    result = run(
      test,
      url:,
      smart_credentials:,
      id_token_fhir_user:
    )

    expect(result.result).to eq('fail')
    expect(user_request).to have_been_made
    expect(result.result_message).to match(/`Access-Control-Allow-Origin` must be/)
  end
end
