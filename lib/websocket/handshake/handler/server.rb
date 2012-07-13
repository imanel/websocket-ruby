module WebSocket
  module Handshake
    module Handler
      module Server

        include Base

        def header_line
          "HTTP/1.1 101 Switching Protocols"
        end

      end
    end
  end
end
