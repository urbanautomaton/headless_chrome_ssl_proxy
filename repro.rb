require 'logger'
require 'selenium/webdriver'
require 'billy'

Billy.configure do |config|
  config.logger = Logger.new('log/billy.log')
end

options = Selenium::WebDriver::Chrome::Options.new
options.headless! if ENV['HEADLESS']
options.add_argument("--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}")

capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
capabilities[:acceptInsecureCerts] = true

browser = Selenium::WebDriver.for(
  :chrome,
  desired_capabilities: capabilities,
  options: options,
  driver_opts: {
    verbose: true,
    log_path: 'log/chromedriver.log'
  }
)

browser.get 'https://example.net/'

if browser.page_source.include?('Example Domain')
  puts 'Pass!'
else
  puts 'Fail!'
end
