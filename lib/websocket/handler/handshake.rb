module WebSocket
  module Handler
    module Handshake

      autoload :Base,     "#{::WebSocket::ROOT}/websocket/handler/handshake/base"

      autoload :Server,   "#{::WebSocket::ROOT}/websocket/handler/handshake/server"
      autoload :Server04, "#{::WebSocket::ROOT}/websocket/handler/handshake/server04"

    end
  end
end
