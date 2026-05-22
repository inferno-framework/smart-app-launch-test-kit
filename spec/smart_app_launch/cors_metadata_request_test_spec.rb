require_relative '../../lib/smart_app_launch/cors_metadata_request_test'

RSpec.describe SMARTAppLaunch::CORSMetadataRequest do
  let(:suite_id) { 'smart_stu2_2' }
  let(:test) { Inferno::Repositories::Tests.new.find('smart_cors_metadata_request') }
  let(:url) { 'http://example.com/fhir' }
  let(:url_same_host) { "#{Inferno::Application['inferno_host']}/fhir" }

  let(:minimal_capabilities) do
    FHIR::CapabilityStatement.new(
      fhirVersion: '4.0.1',
      rest: [
        {
          mode: 'server'
        }
      ]
    )
  end
  let(:results_repo) { Inferno::Repositories::Results.new }

  def entity_result_messages
    results_repo.current_results_for_test_session_and_runnables(test_session.id, [test])
      .first
      .messages
  end

  def cors_header(value)
    {
      'Access-Control-Allow-Origin' => value
    }
  end

  it 'passes when capability statement is returned with valid origin cors header' do
    stub_request(:get, "#{url}/metadata")
      .to_return(status: 200, body: minimal_capabilities.to_json,
                 headers: cors_header(Inferno::Application['inferno_host']))
    result = run(test, url:)

    expect(result.result).to eq('pass')
  end

  it 'passes when capability statement is returned with valid wildcard cors header' do
    stub_request(:get, "#{url}/metadata")
      .to_return(status: 200, body: minimal_capabilities.to_json,
                 headers: cors_header('*'))
    result = run(test, url:)

    expect(result.result).to eq('pass')
  end

  it 'fails when a non-200 response is received' do
    stub_request(:get, "#{url}/metadata")
      .to_return(status: 500, body: minimal_capabilities.to_json,
                 headers: cors_header(Inferno::Application['inferno_host']))

    result = run(test, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/Unexpected response status/)
  end

  it 'fails when a response with no cors header is received' do
    stub_request(:get, "#{url}/metadata")
      .to_return(status: 200, body: minimal_capabilities.to_json)

    result = run(test, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match('No `Access-Control-Allow-Origin` header received')
  end

  it 'passes with an info message when request is to the same host and a response with no cors header is received' do
    stub_request(:get, "#{url_same_host}/metadata")
      .to_return(status: 200, body: minimal_capabilities.to_json)

    result = run(test, url: url_same_host)

    expect(result.result).to eq('pass')
    messages = entity_result_messages
    expect(messages.size).to eq(1)
    expect(messages[0].type).to eq('info')
    expect(messages[0].message).to eq('No CORS headers required: Inferno and the target server are on the same host.')
  end

  it 'fails when a response with incorrect cors header is received' do
    stub_request(:get, "#{url}/metadata")
      .to_return(status: 200, body: minimal_capabilities.to_json,
                 headers: cors_header('https://incorrect-origin.com'))

    result = run(test, url:)

    expect(result.result).to eq('fail')
    expect(result.result_message).to match(/`Access-Control-Allow-Origin` must be/)
  end
end
