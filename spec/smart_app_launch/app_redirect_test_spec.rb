require_relative '../../lib/smart_app_launch/app_redirect_test'
require_relative '../request_helper'

RSpec.describe SMARTAppLaunch::AppRedirectTest do
  include Rack::Test::Methods
  include RequestHelpers

  let(:test) { Inferno::Repositories::Tests.new.find('smart_app_redirect') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:requests_repo) { Inferno::Repositories::Requests.new }
  let(:suite_id) { 'smart'}
  let(:url) { 'http://example.com/fhir' }
  let(:inputs) do
    {
      client_id: 'CLIENT_ID',
      requested_scopes: 'REQUESTED_SCOPES',
      url: url,
      smart_authorization_url: 'http://example.com/auth',
      use_pkce: 'false'
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
        type: type
      )
    end
    Inferno::TestRunner.new(test_session: test_session, test_run: test_run).run(runnable)
  end

  it 'waits and then passes when it receives a request with the correct state' do
    allow(test).to receive(:parent).and_return(Inferno::TestGroup)
    result = run(test, inputs)
    expect(result.result).to eq('wait')

    state = session_data_repo.load(test_session_id: test_session.id, name: 'state')
    get "/custom/smart/redirect?state=#{state}"

    result = results_repo.find(result.id)
    expect(result.result).to eq('pass')
  end

  it 'continues to wait when it receives a request with the incorrect state' do
    result = run(test, inputs)
    expect(result.result).to eq('wait')

    state = SecureRandom.uuid
    get "/custom/smart/redirect?state=#{state}"

    result = results_repo.find(result.id)
    expect(result.result).to eq('wait')
  end

  it 'fails if the authorization url is invalid' do
    inputs[:smart_authorization_url] = 'xyz'
    result = run(test, inputs)
    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/is not a valid URI/)
  end

  it "persists the incoming 'redirect' request" do
    allow(test).to receive(:parent).and_return(Inferno::TestGroup)
    run(test, inputs)
    state = session_data_repo.load(test_session_id: test_session.id, name: 'state')
    url = "/custom/smart/redirect?state=#{state}"
    get url

    request = requests_repo.find_named_request(test_session.id, 'redirect')
    expect(request.url).to end_with(url)
  end

  it "persists the 'state' output" do
    result = run(test, inputs)
    expect(result.result).to eq('wait')

    state = result.result_message.match(/a state of `(.*)`/)[1]
    persisted_state = session_data_repo.load(test_session_id: test_session.id, name: 'state')

    expect(persisted_state).to eq(state)
  end

  context 'when PKCE is enabled' do
    let(:pkce_inputs) do
      pkce_inputs = inputs.merge(pkce_code_challenge_method: 'S256')
      pkce_inputs[:use_pkce] = true
      pkce_inputs
    end

    it 'adds code_challenge and code_challenge method to the authorization url' do
      result = run(test, pkce_inputs)
      expect(result.result).to eq('wait')
      expect(result.result_message).to match(/code_challenge=[a-zA-Z0-9\-_]+/)
      expect(result.result_message).to match(/code_challenge_method=S256/)
    end

    it 'sends the verifier as the challenge when challenge method is plain' do
      result = run(test, pkce_inputs.merge(pkce_code_challenge_method: 'plain'))

      expect(result.result).to eq('wait')
      # We generate a uuid for the verifier, so check that the challenge is a uuid
      expect(result.result_message).to match(/code_challenge=[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}/)
      expect(result.result_message).to match(/code_challenge_method=plain/)
    end
  end

  describe '.calculate_s256_challenge' do
    # https://datatracker.ietf.org/doc/html/rfc7636#appendix-B
    it 'correctly calculates the challenge for the example from the PKCE RFC' do
      verifier = 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk'
      expected_challenge = 'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM'

      challenge = test.calculate_s256_challenge(verifier)

      expect(challenge).to eq(expected_challenge)
    end
  end

  describe '.authorization_url_builder' do
    let(:base_url) { 'https://example.com' }
    let(:new_params) { { one: 1, two: 2 } }

    context 'when there are no existing URL parameters' do
      let(:result) do
        subject.authorization_url_builder(base_url, new_params)
      end

      it { expect(result).to eq "https://example.com?one=1&two=2" }
    end

    context 'when there are existing URL parameters' do
      let(:base_url) { 'https://example.com?keep=me' }
      let(:result) do
        subject.authorization_url_builder(base_url, new_params)
      end

      it { expect(result).to eq "https://example.com?keep=me&one=1&two=2" }
    end

    context 'when a URL parameter value is nil' do
      let(:new_params) { { one: 1, empty: nil } }
      let(:result) do
        subject.authorization_url_builder(base_url, new_params)
      end

      # an empty query parameter is not disallowed by RFC3986, although weird
      it { expect(result).to eq "https://example.com?one=1&empty" }
    end
  end
end
