module WebSocket
  module Handshake
    module Handler

      autoload :Base,     "#{::WebSocket::ROOT}/websocket/handshake/handler/base"

      autoload :Client,   "#{::WebSocket::ROOT}/websocket/handshake/handler/client"

      autoload :Server,   "#{::WebSocket::ROOT}/websocket/handshake/handler/server"
      autoload :Server04, "#{::WebSocket::ROOT}/websocket/handshake/handler/server04"

    end
  end
end
