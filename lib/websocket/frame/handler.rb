module WebSocket
  module Frame
    module Handler

      autoload :Base,     "#{::WebSocket::ROOT}/websocket/frame/handler/base"

      autoload :Handler75, "#{::WebSocket::ROOT}/websocket/frame/handler/handler75"

    end
  end
end
