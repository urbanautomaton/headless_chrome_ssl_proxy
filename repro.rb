require 'logger'
require 'selenium/webdriver'

chrome_args = [ "--disable-web-security" ]
chrome_args.push("--headless") if ENV["HEADLESS"]

case ENV['PROXY']
when 'billy' then
  require 'billy'
  Billy.configure do |config|
    config.logger = Logger.new('log/billy.log')
    config.proxy_host = '127.0.0.1'
    config.proxy_port = 8081
  end
  chrome_args.push("--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}")
  puts "Billy proxy started on #{Billy.proxy.host}:#{Billy.proxy.port}"
when 'browsermob' then
  require 'browsermob/proxy'
  server = BrowserMob::Proxy::Server.new("bin/browsermob-proxy-2.1.4/bin/browsermob-proxy", log: false)
  server.start
  proxy = server.create_proxy
  chrome_args.push("--proxy-server=#{proxy.host}:#{proxy.port}")
  puts "Browsermob proxy started on #{Billy.proxy.host}:#{Billy.proxy.port}"
else
  warn "Unrecognised PROXY (billy|browsermob)"
  exit 1
end

capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
  "chromeOptions" => {
    "args" => chrome_args,
    "useAutomationExtension" => false
  },
  "acceptInsecureCerts" => true
)

begin
  puts "Starting Chrome with #{chrome_args.inspect}"
  driver = Selenium::WebDriver.for(:remote, desired_capabilities: capabilities)

  puts "Navigating to page"
  driver.navigate.to 'https://example.net/'

  if driver.page_source.include?('Example Domain')
    puts 'Pass!'
  else
    puts 'Fail!'
  end
ensure
  if driver
    driver.close
    driver.quit
  end
end
