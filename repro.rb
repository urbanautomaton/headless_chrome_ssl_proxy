require 'pry'
require 'logger'
require 'selenium/webdriver'
require 'billy'

Billy.configure do |config|
  config.logger = Logger.new('log/billy.log')
end

class Billy::ProxyConnection
  alias_method :orig_on_message_complete, :on_message_complete

  def receive_data(data)
    if data =~ /example.net/
      puts
      puts "DATADATADATA"
      puts data
      puts "DATADATADATA"
      puts
    end
    @parser << data
  end

  def on_message_complete
    puts [@parser.http_method, @parser.request_url, @parser.headers.inspect].join(" ")
    orig_on_message_complete
  end

  def restart_with_ssl(url)
    @ssl = url
    @parser = Http::Parser.new(self)
    puts "Responding to CONNECT"
    send_data("HTTP/1.1 200 Connection established\r\nConnection: keep-alive\r\nVia: 1.1 puffing-billy\r\n\r\n")
    puts "Starting TLS"
    start_tls(certificate_chain(url))
  end
end

chrome_args = [
  "--disable-web-security",
  "--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}"
]
chrome_args.push("--headless") if ENV["HEADLESS"]

capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
  "chromeOptions" => {
    "args" => chrome_args,
    "useAutomationExtension" => false
  },
  "acceptInsecureCerts" => true
)

begin
  driver = Selenium::WebDriver.for(:remote, desired_capabilities: capabilities)
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
