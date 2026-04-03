begin
  require 'selenium-webdriver'
rescue LoadError
  warn 'selenium-webdriver is required to run this command script.'
  warn "Add it to your Gemfile: gem 'selenium-webdriver'"
  exit(1)
end
require 'faraday'
require 'json'

session_id = ARGV[0]
target_suite = ARGV[1]
continuation_url = ARGV[2]
patient_id = ARGV[3]
inferno_host = ARGV[4]

inputs_cli_command = "bundle exec inferno session data #{session_id}#{" -I #{inferno_host}" unless inferno_host.nil?}"
inputs = JSON.parse(`#{inputs_cli_command}`)
token = inputs.find { |input| input['name'] == 'bearer_token' }&.dig('value')
raise StandardError, 'could not find access token to revoke' if token.nil? || token == ''

suite_base_url = continuation_url.split(target_suite).first
read_url = "#{suite_base_url}#{target_suite}/fhir/Patient/#{patient_id}"

Faraday.get(read_url, nil, :Authorization => "Bearer #{token}")
options = Selenium::WebDriver::Options.chrome(args: ['--headless=new'])
driver = Selenium::WebDriver.for(:chrome, options: options)
wait = Selenium::WebDriver::Wait.new(timeout: 10)
driver.get continuation_url
wait.until { driver.find_element(:xpath, '//title') }
driver.quit
exit(0)





