module WebSocket
  module Handshake

    autoload :Base,   "#{::WebSocket::ROOT}/websocket/handshake/base"
    autoload :Client, "#{::WebSocket::ROOT}/websocket/handshake/client"
    autoload :Server, "#{::WebSocket::ROOT}/websocket/handshake/server"

  end
end
