require 'selenium/webdriver'
require 'browsermob/proxy'

server = BrowserMob::Proxy::Server.new("bin/browsermob-proxy-2.1.4/bin/browsermob-proxy", log: true)
server.start

proxy = server.create_proxy
proxy.blacklist('https://example.net/', 200)

puts "press ctrl-c to exit"
sleep

chrome_args = [
  "--disable-web-security",
  "--proxy-server=#{proxy.host}:#{proxy.port}"
]
chrome_args.push("--headless") if ENV["HEADLESS"]

capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
  "chromeOptions" => { "args" => chrome_args },
  "useAutomationExtension" => false,
  "acceptInsecureCerts" => true
)

begin
  puts "Starting Chrome with #{chrome_args.inspect}"
  driver = Selenium::WebDriver.for(:remote, desired_capabilities: capabilities)
  driver.navigate.to 'https://example.net/'

  if driver.page_source.include?('Example Domain')
    puts 'Pass!'
  else
    puts driver.page_source
    puts 'Fail!'
  end
ensure
  driver.close
  driver.quit
end
