require 'logger'
require 'selenium/webdriver'

chrome_args = [ "--disable-web-security" ]
chrome_args.push("--headless") if ENV["HEADLESS"] == 'true'

case ENV['PROXY']
when 'billy' then
  require 'billy'
  Billy.configure do |config|
    config.logger = Logger.new('log/billy.log')
    config.proxy_host = '127.0.0.1'
    config.proxy_port = 8081
    config.non_whitelisted_requests_disabled = true
  end
  chrome_args.push("--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}")
  Billy.proxy.stub("https://example.net:443/").and_return(body: "Example Domain")
  puts "Billy proxy started on #{Billy.proxy.host}:#{Billy.proxy.port}"
when 'browsermob' then
  require 'browsermob/proxy'
  server = BrowserMob::Proxy::Server.new("bin/browsermob-proxy-2.1.4/bin/browsermob-proxy", log: false)
  server.start
  proxy = server.create_proxy
  chrome_args.push("--proxy-server=#{proxy.host}:#{proxy.port}")
  puts "Browsermob proxy started on #{proxy.host}:#{proxy.port}"
when 'mitmproxy' then
  mitmproxy_pid = Process.spawn('mitmdump -q')
  chrome_args.push("--proxy-server=127.0.0.1:8080")
else
  warn "Unrecognised PROXY (billy|browsermob|mitmproxy)"
  exit 1
end

capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
  "chromeOptions" => {
    "args" => chrome_args,
    "useAutomationExtension" => false
  },
  "acceptInsecureCerts" => true
)

puts "Starting Chrome with #{chrome_args.inspect}"
driver = Selenium::WebDriver.for(
  :chrome,
  desired_capabilities: capabilities,
  driver_opts: {
    verbose: true,
    log_path: 'log/chromedriver.log'
  }
)

puts "Navigating to page"
driver.navigate.to 'https://example.net/'

if driver.page_source.include?('Example Domain')
  puts 'Pass!'
else
  puts driver.page_source
  puts 'Fail!'
end

at_exit do
  Process.kill('TERM', mitmproxy_pid) if mitmproxy_pid
  if driver
    driver.close
    driver.quit
  end
end
