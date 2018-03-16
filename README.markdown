# Reproduction of headless chrome hang with proxied secure URLs

This is an attempt to minimally reproduce an issue where using
chromedriver with the following options will cause it to hang when
visiting a secure URL:

* `--headless`
* `acceptInsecureCerts = true`
* `--proxy-server=...`

The reproduction uses the [selenium-webdriver
gem](https://github.com/SeleniumHQ/selenium/tree/master/rb) to manage
chromedriver, and the proxy server used is
[puffing-billy](https://github.com/oesmith/puffing-billy), a ruby proxy
used to stub remote requests for testing purposes.

## Usage

Clone the repo and install dependencies:

    $ git clone https://github.com/urbanautomaton/headless_chrome_ssl_proxy
    $ bundle install

Run the test without headless mode:

    $ bundle exec ruby repro.rb
    Pass!

This should pass.

Run the test in headless mode:

    $ HEADLESS=true bundle exec ruby repro.rb

This should block for ~1 minute, then fail with a `Errno::ECONNREFUSED`
(itself occurring in an attempt to recover from a `Net::ReadTimeout`).

## Versions

Tested with:

* MRI Ruby 2.4.3
* selenium-webdriver 3.11.0
* puffing-billy 1.0.0
* Chrome 65.0.3325.162 / macOS 10.13.3

## Output

Chromedriver logs and puffing-billy logs are written to `log/`, while
sample logs for headless and non-headless runs are included in
`example/`.
