require 'selenium/webdriver'
require 'billy/capybara/rspec'
require 'capybara/rspec'

class App
  def call(_)
    [
      '200',
      { 'Content-Type' => 'text/html' },
      [
        <<~HTML
          <html>
          <body>
          <iframe src="https://example.net/" id="iframe"></iframe>
          </body>
          </html>
        HTML
      ]
    ]
  end
end

Capybara.app = App.new

Billy.configure do |c|
  c.non_whitelisted_requests_disabled = true
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.headless! if ENV['HEADLESS']
  options.add_argument("--proxy-server=#{Billy.proxy.host}:#{Billy.proxy.port}")

  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome
  capabilities[:acceptInsecureCerts] = true

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities,
    options: options
  )
end

RSpec.configure do |config|
  config.before(:each, type: :feature) do
    Capybara.current_driver = :headless_chrome
  end
end

RSpec.describe App do
  it 'does stuff', type: :feature do
    proxy.stub('https://example.net:443/').and_return(:text => 'Foobar')

    visit '/'

    within_frame("iframe") do
      expect(page).to have_content('Foobar')
    end
  end
end
