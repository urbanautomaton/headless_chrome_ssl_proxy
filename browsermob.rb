require 'browsermob/proxy'

server = BrowserMob::Proxy::Server.new("bin/browsermob-proxy-2.1.4/bin/browsermob-proxy", log: true)
server.start
proxy = server.create_proxy

puts "Browsermob running on #{proxy.host}:#{proxy.port}"

sleep
