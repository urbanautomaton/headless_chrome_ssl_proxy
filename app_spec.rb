require 'logger'
require 'selenium/webdriver'
require 'billy'

Billy.configure do |config|
  config.logger = Logger.new('log/billy.log')
end

RSpec.describe 'Proxied HTTPS requests' do
  let(:browser) do
    options = Selenium::WebDriver::Chrome::Options.new
    options.headless! if ENV['HEADLESS']
    options.add_argument("--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}")

    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
    capabilities[:acceptInsecureCerts] = true

    Selenium::WebDriver.for(
      :chrome,
      desired_capabilities: capabilities,
      options: options,
      driver_opts: {
        verbose: true,
        log_path: 'log/chromedriver.log'
      }
    )
  end

  it 'makes a request via the proxy', type: :feature do
    browser.get 'https://example.net/'

    expect(browser.page_source).to include('Example Domain')
  end
end
