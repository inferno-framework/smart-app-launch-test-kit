begin
  require 'selenium-webdriver'
rescue LoadError
  warn 'selenium-webdriver is required to run this command script.'
  warn "Add it to your Gemfile: gem 'selenium-webdriver'"
  exit(1)
end

target_url = ARGV[0]

options = Selenium::WebDriver::Options.chrome(args: ['--headless=new'])
driver = Selenium::WebDriver.for(:chrome, options: options)
wait = Selenium::WebDriver::Wait.new(timeout: 10)
driver.get target_url
wait.until { driver.find_element(:xpath, '//title') }
driver.quit
exit(0)
