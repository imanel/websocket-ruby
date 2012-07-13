module WebSocket
  module Handler
    module Handshake
      module Server

        include Base

        def header_line
          "HTTP/1.1 101 Switching Protocols"
        end

      end
    end
  end
end
