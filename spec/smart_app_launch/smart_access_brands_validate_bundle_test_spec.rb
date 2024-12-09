require_relative '../../lib/smart_app_launch/smart_access_brands_retrieve_bundle_test'

RSpec.describe SMARTAppLaunch::SMARTAccessBrandsValidateBundle do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('smart_access_brands') }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: 'smart_access_brands') }
  let(:result) { repo_create(:result, test_session_id: test_session.id) }

  let(:smart_access_brands_bundle) do
    JSON.parse(File.read(File.join(
                           __dir__, '..', 'fixtures', 'smart_access_brands_example.json'
                         )))
  end

  let(:operation_outcome_success) do
    {
      outcomes: [{
        issues: []
      }],
      sessionId: 'b8cf5547-1dc7-4714-a797-dc2347b93fe2'
    }
  end

  let(:operation_outcome_failure) do
    {
      outcomes: [{
        issues: [{
          level: 'ERROR',
          message: 'Resource does not conform to profile'
        }]
      }],
      sessionId: 'b8cf5547-1dc7-4714-a797-dc2347b93fe2'
    }
  end

  let(:validator_url) { ENV.fetch('FHIR_RESOURCE_VALIDATOR_URL') }
  let(:user_access_brands_publication_url) { 'http://fhirserver.org/smart_access_brands_example.json' }

  def create_user_access_brands_request(url: user_access_brands_publication_url, body: nil, status: 200)
    repo_create(
      :request,
      name: 'retrieve_smart_access_brands_bundle',
      direction: 'outgoing',
      url:,
      result:,
      test_session_id: test_session.id,
      response_body: body.is_a?(Hash) ? body.to_json : body,
      status:,
      tags: ['smart_access_brands_bundle']
    )
  end

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(
        test_session_id: test_session.id,
        name:,
        value:,
        type: runnable.config.input_type(name) || 'text'
      )
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable)
  end

  describe 'SMART Access Brands Validate Bundle Test' do
    let(:test) do
      Class.new(SMARTAppLaunch::SMARTAccessBrandsValidateBundle) do
        fhir_resource_validator do
          url ENV.fetch('FHIR_RESOURCE_VALIDATOR_URL')

          cli_context do
            txServer nil
            displayWarnings true
            disableDefaultResourceFetcher true
          end

          igs('hl7.fhir.uv.smart-app-launch#2.2.0')
        end
      end
    end

    it 'passes if User Access Brands Bundle is valid' do
      create_user_access_brands_request(body: smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('pass')
    end

    it 'passes if inputted User Access Brands Bundle is valid' do
      result = run(test, user_access_brands_bundle: smart_access_brands_bundle.to_json)

      expect(result.result).to eq('pass')
    end

    it 'passes if a valid User Access Brands Bundle was received and resource_validation_limit input is entered' do
      create_user_access_brands_request(body: smart_access_brands_bundle)

      result = run(test, resource_validation_limit: 2)

      expect(result.result).to eq('pass')
    end

    it 'skips if no User Access Brands Bundle requests were made' do
      result = run(test)

      expect(result.result).to eq('skip')
      expect(result.result_message).to match(
        'No User Access Brands request was made in the previous test, and no User Access Brands Bundle was provided'
      )
    end

    it 'skips if User Access Brands Bundle request does not contain a response body' do
      create_user_access_brands_request
      result = run(test)

      expect(result.result).to eq('skip')
      expect(result.result_message).to match('No successful User Access Brands request was made in the previous test')
    end

    it 'fails if User Access Brands Bundle is an invalid JSON' do
      create_user_access_brands_request(body: '[[')

      result = run(test)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('Invalid JSON. ')
    end

    it 'fails if User Access Brands response is not a Bundle' do
      smart_access_brands_bundle['resourceType'] = 'Patient'
      create_user_access_brands_request(body: smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('Unexpected resource type: expected Bundle, but received Patient')
    end

    it 'fails if the User Access Brands Bundle contains duplicate fullUrls' do
      smart_access_brands_bundle['entry'].first['fullUrl'] = 'https://ehr1.fhirserver.com/Endpoint/examplehospital-ehr1'
      create_user_access_brands_request(body: smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(
        'The SMART Access Brands Bundle contains entries with duplicate fullUrls'
      )
    end

    it 'fails if the User Access Brands Bundle contains an entry with the request field' do
      smart_access_brands_bundle['entry'].first['request'] = { 'method' => 'GET', 'url' => 'examplerequest.com' }
      create_user_access_brands_request(body: smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(
        'Bundle entry 1 contains the `request` field'
      )
    end

    it 'fails if the User Access Brands Bundle contains an entry with a version specific fullUrl reference' do
      smart_access_brands_bundle['entry'].first['fullUrl'] = 'examplerequest.com/_history/2'
      create_user_access_brands_request(body: smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(result.result_message).to match(
        'Bundle entry 1 contains a version specific reference'
      )
    end

    it 'fails if User Access Brands Bundle is not type collection' do
      smart_access_brands_bundle['type'] = 'history'
      create_user_access_brands_request(body: smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('The SMART Access Brands Bundle must be type `collection`')
    end

    it 'fails if User Access Brands Bundle does not have the timestamp field populated' do
      smart_access_brands_bundle.delete('timestamp')
      create_user_access_brands_request(body: smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq(
        'Bundle.timestamp must be populated to advertise the timestamp of the last change to the contents'
      )
    end

    it 'fails if User Access Brands Bundle is empty' do
      smart_access_brands_bundle['entry'] = []
      create_user_access_brands_request(body: smart_access_brands_bundle)
      result = run(test)

      expect(result.result).to eq('fail')
      expect(result.result_message).to eq('The given Bundle does not contain any brands or endpoints.')
    end
  end
end
