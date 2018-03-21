require 'billy'

class Billy::ProxyConnection
  alias_method :orig_on_message_complete, :on_message_complete

  def on_message_complete
    puts [@parser.http_method, @parser.request_url, @parser.headers.inspect].join(" ")
    orig_on_message_complete
  end
end

puts "Billy running on #{Billy.proxy.host}:#{Billy.proxy.port}"

sleep
