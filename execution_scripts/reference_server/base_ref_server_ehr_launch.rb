begin
  require 'selenium-webdriver'
rescue LoadError
  warn 'selenium-webdriver is required to run this command script.'
  warn "Add it to your Gemfile: gem 'selenium-webdriver'"
  exit(1)
end

def ref_server_ehr_launch(launch_url, reference_server_fhir_base, target_patient_id)
  reference_server_url = reference_server_fhir_base.chomp('/r4')
  launch_screen_url = "#{reference_server_url}/app/app-launch"
  
  options = Selenium::WebDriver::Options.chrome(args: ['--headless=new'])
  driver = Selenium::WebDriver.for(:chrome, options: options)
  wait = Selenium::WebDriver::Wait.new(timeout: 10)
  driver.get launch_screen_url
  wait.until { driver.find_element(id: 'patientSelector').text.strip != 'Loading...' }
  driver.find_element(id: 'patientSelector').find_element(:xpath, "option[text()='#{target_patient_id}']").click
  driver.find_element(id: 'appURI').send_keys(launch_url)
  driver.find_element(id: 'launchAppButton').click
  wait.until { driver.find_element(:xpath, "//h2[text()='User Action Required']") }
  driver.quit
  exit(0)
end
