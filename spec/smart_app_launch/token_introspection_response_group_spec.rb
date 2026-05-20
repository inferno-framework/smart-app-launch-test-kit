require_relative '../../lib/smart_app_launch/token_introspection_response_group'

RSpec.describe SMARTAppLaunch::SMARTTokenIntrospectionResponseGroup, :request do
  let(:active_test) { Inferno::Repositories::Tests.new.find('smart_token_introspection_response_group-Test01') }
  let(:inactive_test) { Inferno::Repositories::Tests.new.find('smart_token_introspection_response_group-Test02') }
  let(:suite_id) { 'smart'}

  context 'for inactive tokens' do
    it 'passes when active=false' do
      inputs = {
        invalid_token_introspection_response_body: {
          "active": false
        }.to_json
      }

      result = run(inactive_test, inputs)

      expect(result.result).to eq('pass')
    end

    it 'fails when active=true' do
      inputs = {
        invalid_token_introspection_response_body: {
          "active": true
        }.to_json
      }

      result = run(inactive_test, inputs)

      expect(result.result).to eq('fail')
    end

     it 'warns when additional information' do
      inputs = {
        invalid_token_introspection_response_body: {
          "active": false,
          "resource": "extra_details"
        }.to_json
      }
      result = run(inactive_test, inputs)

      expect(result.result).to eq('pass')      
      result_messages = Inferno::Repositories::Messages.new.messages_for_result(result.id)
      expect(result_messages.find { |m| /should not contain additional information/.match(m.message) }).to_not be_nil
    end
  end

 
end
