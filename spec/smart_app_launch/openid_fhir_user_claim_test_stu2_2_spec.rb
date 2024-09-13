require_relative '../../lib/smart_app_launch/openid_fhir_user_claim_test_stu2_2'

RSpec.describe SMARTAppLaunch::OpenIDFHIRUserClaimTestSTU22 do
  let(:test) { Inferno::Repositories::Tests.new.find('smart_openid_fhir_user_claim_stu2_2') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_stu2_2') }
  let(:url) { 'http://example.com/fhir' }
  let(:scopes) { 'fhirUser' }
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
  let(:payload) do
    {
      fhirUser: "#{url}/Patient/123"
    }
  end
  let(:cors_header) do
    {
      'Access-Control-Allow-Origin' => Inferno::Application['base_url']
    }
  end
  let(:incorrect_cors_header) do
    {
      'Access-Control-Allow-Origin' => 'https://incorrect-origin.com'
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

  it 'skips if no token payload is available' do
    result = run(test, id_token_payload_json: nil, url:, smart_credentials:)

    expect(result.result).to eq('skip')
  end

  it 'skips if no fhirUser scope was requested' do
    result = run(
      test,
      id_token_payload_json: nil,
      requested_scopes: 'launch',
      url:,
      smart_credentials:
    )

    expect(result.result).to eq('skip')
  end

  it 'passes when the fhirUser claim is present and the user can be retrieved' do
    user_request =
      stub_request(:get, payload[:fhirUser])
        .to_return(status: 200, body: FHIR::Patient.new(id: '123').to_json, headers: cors_header)
    result = run(
      test,
      id_token_payload_json: payload.to_json,
      requested_scopes: scopes,
      url:,
      smart_credentials:
    )

    expect(result.result).to eq('pass')
    expect(user_request).to have_been_made
  end

  it 'fails if the fhirUser claim is blank' do
    result = run(
      test,
      id_token_payload_json: { fhirUser: '' }.to_json,
      requested_scopes: scopes,
      url:,
      smart_credentials:
    )

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/does not contain/)
  end

  it 'fails if the fhirUser claim does not refer to a valid resource type' do
    result = run(
      test,
      id_token_payload_json: { fhirUser: "#{url}/Observation/123" }.to_json,
      requested_scopes: scopes,
      url:,
      smart_credentials:
    )

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/resource type/)
  end

  it 'fails if the incorrect resource type is returned' do
    user_request =
      stub_request(:get, payload[:fhirUser])
        .to_return(status: 200, body: FHIR::Person.new(id: '123').to_json, headers: cors_header)
    result = run(
      test,
      id_token_payload_json: { fhirUser: "#{url}/Patient/123" }.to_json,
      requested_scopes: scopes,
      url:,
      smart_credentials:
    )

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Patient/)
    expect(user_request).to have_been_made
  end

  it 'fails when the fhirUser can not be retrieved' do
    user_request =
      stub_request(:get, payload[:fhirUser])
        .to_return(status: 404)
    result = run(
      test,
      id_token_payload_json: payload.to_json,
      requested_scopes: scopes,
      url:,
      smart_credentials:
    )

    expect(result.result).to eq('fail')
    expect(result.result_message).to include('200')
    expect(user_request).to have_been_made
  end

  it 'fails when the fhirUser is returned with no cors header' do
    user_request =
      stub_request(:get, payload[:fhirUser])
        .to_return(status: 200, body: FHIR::Patient.new(id: '123').to_json)
    result = run(
      test,
      id_token_payload_json: payload.to_json,
      requested_scopes: scopes,
      url:,
      smart_credentials:
    )

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(
      'No `Access-Control-Allow-Origin` header received'
    )
    expect(user_request).to have_been_made
  end

  it 'fails when the fhirUser is returned with incorrect cors header' do
    user_request =
      stub_request(:get, payload[:fhirUser])
        .to_return(status: 200, body: FHIR::Patient.new(id: '123').to_json, headers: incorrect_cors_header)
    result = run(
      test,
      id_token_payload_json: payload.to_json,
      requested_scopes: scopes,
      url:,
      smart_credentials:
    )

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/`Access-Control-Allow-Origin` must be/)
    expect(user_request).to have_been_made
  end

  it 'persists outputs' do
    stub_request(:get, payload[:fhirUser])
      .to_return(status: 200, body: FHIR::Patient.new(id: '123').to_json, headers: cors_header)
    result = run(
      test,
      id_token_payload_json: payload.to_json,
      requested_scopes: scopes,
      url:,
      smart_credentials:
    )

    expect(result.result).to eq('pass')

    persisted_user = session_data_repo.load(test_session_id: test_session.id, name: :id_token_fhir_user)
    expect(persisted_user).to eq(payload[:fhirUser])
  end
end
