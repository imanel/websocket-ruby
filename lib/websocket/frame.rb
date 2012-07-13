module WebSocket
  module Frame

    autoload :Incoming, "#{::WebSocket::ROOT}/websocket/frame/incoming"
    autoload :Outgoing, "#{::WebSocket::ROOT}/websocket/frame/outgoing"

  end
end
