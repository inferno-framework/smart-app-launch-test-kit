require_relative '../../lib/smart_app_launch/discovery_stu1_group'

RSpec.describe SMARTAppLaunch::DiscoverySTU22Group do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('smart_stu2_2') }
  let(:group) { Inferno::Repositories::TestGroups.new.find('smart_discovery_stu2_2') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_stu2_2') }
  let(:url) { 'http://example.com/fhir' }

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

  describe 'capability statement CORS test' do
    let(:runnable) { group.tests[3] }
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

    it 'passes when capability statement is returned with valid origin cors header' do
      stub_request(:get, "#{url}/metadata")
        .to_return(status: 200, body: minimal_capabilities.to_json,
                   headers: cors_header(Inferno::Application['inferno_host']))
      result = run(runnable, url:)

      expect(result.result).to eq('pass')
    end

    it 'passes when capability statement is returned with valid wildcard cors header' do
      stub_request(:get, "#{url}/metadata")
        .to_return(status: 200, body: minimal_capabilities.to_json,
                   headers: cors_header('*'))
      result = run(runnable, url:)

      expect(result.result).to eq('pass')
    end

    it 'fails when a non-200 response is received' do
      stub_request(:get, "#{url}/metadata")
        .to_return(status: 500, body: minimal_capabilities.to_json,
                   headers: cors_header(Inferno::Application['inferno_host']))

      result = run(runnable, url:)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/Unexpected response status/)
    end

    it 'fails when a response with no cors header is received' do
      stub_request(:get, "#{url}/metadata")
        .to_return(status: 200, body: minimal_capabilities.to_json)

      result = run(runnable, url:)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match('No `Access-Control-Allow-Origin` header received')
    end

    it 'fails when a response with incorrect cors header is received' do
      stub_request(:get, "#{url}/metadata")
        .to_return(status: 200, body: minimal_capabilities.to_json,
                   headers: cors_header('https://incorrect-origin.com'))

      result = run(runnable, url:)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(/`Access-Control-Allow-Origin` must be/)
    end
  end
end
