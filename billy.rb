require 'logger'
require 'billy'

Billy.configure do |config|
  # config.logger = Logger.new('log/billy.log')
  config.proxy_host = '127.0.0.1'
  config.proxy_port = 8081
end

puts "Billy running on #{Billy.proxy.host}:#{Billy.proxy.port}"

sleep
