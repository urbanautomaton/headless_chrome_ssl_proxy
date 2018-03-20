require 'logger'
require 'selenium/webdriver'
require 'billy'

Billy.configure do |config|
  config.logger = Logger.new('log/billy.log')
end

chrome_args = [
  "--disable-web-security",
  "--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}"
]
chrome_args.push("--headless") if ENV["HEADLESS"]

capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
  "chromeOptions" => { "args" => chrome_args },
  "acceptInsecureCerts" => true
)

driver = Selenium::WebDriver.for(:remote, desired_capabilities: capabilities)

driver.navigate.to 'https://example.net/'

if driver.page_source.include?('Example Domain')
  puts 'Pass!'
else
  puts 'Fail!'
end
