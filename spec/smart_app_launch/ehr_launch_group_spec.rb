require_relative '../../lib/smart_app_launch/ehr_launch_group'
require_relative '../request_helper'

RSpec.describe SMARTAppLaunch::EHRLaunchGroup do
  include Rack::Test::Methods
  include RequestHelpers

  let(:suite) { Inferno::Repositories::TestSuites.new.find('smart') }
  let(:group) { Inferno::Repositories::TestGroups.new.find('smart_ehr_launch') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:requests_repo) { Inferno::Repositories::Requests.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart') }
  let(:url) { 'http://example.com/fhir' }
  let(:token_url) { "#{url}/token" }
  let(:inputs) do
    base_inputs = {
      url: url,
      smart_authorization_url: "#{url}/auth",
      smart_token_url: token_url,
      client_id: 'CLIENT_ID',
      requested_scopes: 'launch/patient patient/*.*',
      client_auth_type: 'public',
      pkce_support: 'disabled'
    }
    if SMARTAppLaunch::Feature.use_auth_info?
      base_inputs.merge(
        auth_info: Inferno::DSL::AuthInfo.new(
          client_id: base_inputs[:client_id],
          requested_scopes: base_inputs[:requested_scopes],
          pkce_support: base_inputs[:pkce_support]
        )
      ).except(:client_id, :requested_scopes, :pkce_support)
    else
      base_inputs
    end
  end
  let(:token_response) do
    {
      access_token: 'ACCESS_TOKEN',
      id_token: 'ID_TOKEN',
      refresh_token: 'REFRESH_TOKEN',
      expires_in: 3600,
      patient: '123',
      encounter: '456',
      scope: 'launch/patient patient/*.*',
      intent: 'INTENT',
      token_type: 'Bearer'
    }
  end
  let(:token_response_headers) do
    {
      'Cache-Control' => 'no-store',
      'Pragma' => 'no-cache'
    }
  end

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      type = runnable.config.input_type(name).presence || 'text'
      type = 'text' if type == 'radio'
      session_data_repo.save(
        test_session_id: test_session.id,
        name: runnable.config.input_name(name).presence || name,
        value: value,
        type: type
      )
    end
    Inferno::TestRunner.new(test_session: test_session, test_run: test_run).run(runnable)
  end

  it 'persists requests and outputs' do
    stub_request(:get, 'https://example.com:80/fhir/auth')
      .to_raise(StandardError)
      .times(4)
      .then
      .to_return(status: 200)
    stub_request(:get, 'https://example.com:80/fhir/token')
      .to_raise(StandardError)
      .times(4)
      .then
      .to_return(status: 200)
    stub_request(:post, token_url)
      .to_return(status: 200, body: token_response.to_json, headers: token_response_headers)
    run(group, inputs)

    get "/custom/smart/launch?launch=LAUNCH&iss=#{url}"

    state = session_data_repo.load(test_session_id: test_session.id, name: 'ehr_state')
    get "/custom/smart/redirect?state=#{state}&code=CODE"

    results = results_repo.current_results_for_test_session(test_session.id)
    expect(results.map(&:result)).to all(eq('pass'))

    expected_outputs = {
      ehr_launch: 'LAUNCH',
      ehr_access_token: token_response[:access_token],
      ehr_id_token: token_response[:id_token],
      ehr_refresh_token: token_response[:refresh_token],
      ehr_expires_in: token_response[:expires_in],
      ehr_patient_id: token_response[:patient],
      ehr_encounter_id: token_response[:encounter],
      ehr_received_scopes: token_response[:scope],
      ehr_intent: token_response[:intent]
    }
    other_outputs = %i[ehr_code ehr_state ehr_token_retrieval_time]

    expected_outputs.each do |name, value|
      expect(session_data_repo.load(test_session_id: test_session.id, name: name)).to eq(value.to_s)
    end

    other_outputs.each do |name|
      expect(session_data_repo.load(test_session_id: test_session.id, name: name)).to be_present
    end

    %i[ehr_launch ehr_redirect ehr_token].each do |name|
      expect(requests_repo.find_named_request(test_session.id, name)).to be_present
    end
  end
end
