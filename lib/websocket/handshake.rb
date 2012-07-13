module WebSocket
  module Handshake

    autoload :Client, "#{::WebSocket::ROOT}/websocket/handshake/client"
    autoload :Server, "#{::WebSocket::ROOT}/websocket/handshake/server"

  end
end
