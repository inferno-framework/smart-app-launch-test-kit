RSpec.describe SMARTAppLaunch::SMARTClientTokenUseVerification do # rubocop:disable RSpec/SpecFilePathFormat
  let(:suite_id) { 'smart_client_stu2_2' }
  let(:test) { described_class }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:dummy_result) { repo_create(:result, test_session_id: test_session.id) }
  let(:token_endpoint) { 'https://inferno.healthit.gov/suites/custom/smart_client_stu2_2/auth/token' }
  let(:access_endpoint) { 'https://inferno.healthit.gov/suites/custom/smart_client_stu2_2/fhir/Patient/999' }
  let(:jwks_valid) do
    File.read(File.join(__dir__, '..', '..', '..', 'lib', 'smart_app_launch', 'smart_jwks.json'))
  end

  def create_access_request(access_token)
    headers ||= [
      {
        type: 'request',
        name: 'Authorization',
        value: "Bearer #{access_token}"
      }
    ]
    repo_create(
      :request,
      direction: 'incoming',
      url: access_endpoint,
      result: dummy_result,
      test_session_id: test_session.id,
      status: 200,
      tags: [SMARTAppLaunch::ACCESS_TAG],
      headers:
    )
  end

  it 'skips if no input tokens' do
    result = run(test, smart_jwk_set: jwks_valid)
    expect(result.result).to eq('skip')
  end

  it 'skips if no access requests' do
    smart_tokens = "abc\n123"
    result = run(test, smart_jwk_set: jwks_valid, smart_tokens:)
    expect(result.result).to eq('skip')
  end

  it 'passes an input access token is used in an access request' do
    smart_tokens = "abc\n123"
    create_access_request('123')
    result = run(test, smart_jwk_set: jwks_valid, smart_tokens:)
    expect(result.result).to eq('pass')
  end

  it 'fails if no input access token was used on an access request' do
    smart_tokens = "abc\n123"
    create_access_request('xyz')
    result = run(test, smart_jwk_set: jwks_valid, smart_tokens:)
    expect(result.result).to eq('fail')
  end

end
