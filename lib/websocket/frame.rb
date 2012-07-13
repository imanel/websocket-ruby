module WebSocket
  module Frame

    autoload :Base,     "#{::WebSocket::ROOT}/websocket/frame/base"
    autoload :Incoming, "#{::WebSocket::ROOT}/websocket/frame/incoming"
    autoload :Outgoing, "#{::WebSocket::ROOT}/websocket/frame/outgoing"

  end
end
