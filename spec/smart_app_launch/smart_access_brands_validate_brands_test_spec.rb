require_relative '../../lib/smart_app_launch/smart_access_brands_retrieve_bundle_test'

RSpec.describe SMARTAppLaunch::SMARTAccessBrandsValidateBrands do
  let(:suite_id) { 'smart_access_brands' }
  let(:results_repo) { Inferno::Repositories::Results.new }
  let(:result) { repo_create(:result, test_session_id: test_session.id) }
  let(:runnable) { Inferno::Repositories::Tests.new.find('smart_access_brands_valid_brands') }

  let(:smart_access_brands_bundle) do
    FHIR.from_contents(File.read(File.join(
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

  def entity_result_message
    results_repo.current_results_for_test_session_and_runnables(test_session.id, [runnable])
      .first
      .messages
      .first
  end

  describe 'SMART Access Brands Validate Brands Test' do
    let(:test) do
      Class.new(SMARTAppLaunch::SMARTAccessBrandsValidateBrands) do
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

    it 'passes if User Access Brands Bundle contains valid Brands' do
      validation_request = stub_request(:post, "#{validator_url}/validate")
        .to_return(status: 200, body: operation_outcome_success.to_json)

      allow_any_instance_of(test).to receive(:scratch_bundle_resource).and_return(smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('pass')
      expect(validation_request).to have_been_made.times(2)
    end

    it 'skips if no User Access Brands Bundle requests were made' do
      result = run(test)

      expect(result.result).to eq('skip')
      expect(result.result_message).to match(
        'No successful User Access Brands request was made in the previous test'
      )
    end

    it 'skips if User Access Brands Bundle is empty' do
      smart_access_brands_bundle.entry = []
      allow_any_instance_of(test).to receive(:scratch_bundle_resource).and_return(smart_access_brands_bundle)
      result = run(test)

      expect(result.result).to eq('skip')
      expect(result.result_message).to eq('The given Bundle does not contain any resources')
    end

    it "fails if the User Access Brands Bundle's contained Brands fail validation" do
      validation_request = stub_request(:post, "#{validator_url}/validate")
        .to_return(status: 200, body: operation_outcome_failure.to_json)

      allow_any_instance_of(test).to receive(:scratch_bundle_resource).and_return(smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(entity_result_message.message).to match(
        'Resource does not conform to profile'
      )
      expect(validation_request).to have_been_made.times(2)
    end

    it 'fails if Brand missing endpoint and partOf fields' do
      validation_request = stub_request(:post, "#{validator_url}/validate")
        .to_return(status: 200, body: operation_outcome_success.to_json)
      smart_access_brands_bundle.entry.last.resource.partOf = nil
      allow_any_instance_of(test).to receive(:scratch_bundle_resource).and_return(smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(entity_result_message.message).to match(
        'Organization with id: ehchospital does not have the endpoint or partOf field populated'
      )
      expect(validation_request).to have_been_made.times(2)
    end

    it 'fails if Brand partOf references an Organization that does not exist' do
      validation_request = stub_request(:post, "#{validator_url}/validate")
        .to_return(status: 200, body: operation_outcome_success.to_json)

      smart_access_brands_bundle.entry.shift
      allow_any_instance_of(test).to receive(:scratch_bundle_resource).and_return(smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(entity_result_message.message).to match(
        'Organization with id: ehchospital references parent Organization not found in the Bundle'
      )
      expect(validation_request).to have_been_made.times(1)
    end

    it 'fails if Brand contains Endpoint in portal extension but not Organization.endpoint' do
      validation_request = stub_request(:post, "#{validator_url}/validate")
        .to_return(status: 200, body: operation_outcome_success.to_json)

      smart_access_brands_bundle.entry.first.resource.endpoint.shift
      allow_any_instance_of(test).to receive(:scratch_bundle_resource).and_return(smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(entity_result_message.message).to match('Portal endpoints must also appear at Organization.endpoint')
      expect(validation_request).to have_been_made.times(2)
    end

    it 'fails if Brand contains Endpoint reference not found in Bundle' do
      validation_request = stub_request(:post, "#{validator_url}/validate")
        .to_return(status: 200, body: operation_outcome_success.to_json)

      smart_access_brands_bundle.entry.delete_at(1)
      allow_any_instance_of(test).to receive(:scratch_bundle_resource).and_return(smart_access_brands_bundle)

      result = run(test)

      expect(result.result).to eq('fail')
      expect(entity_result_message.message).to match(
        'Organization with id: examplehospital references an Endpoint'
      )
      expect(validation_request).to have_been_made.times(2)
    end
  end
end
