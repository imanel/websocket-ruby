module WebSocket
  module Handler

    autoload :Base,      "#{::WebSocket::ROOT}/websocket/handler/base"
    autoload :Handler13, "#{::WebSocket::ROOT}/websocket/handler/handler13"

    autoload :Handshake, "#{::WebSocket::ROOT}/websocket/handler/handshake"

  end
end
