module WebSocket
  module Handshake
    module Handler
      module Server75

        include Server

        private

        def header_line
          "HTTP/1.1 101 Web Socket Protocol Handshake"
        end

        def handshake_keys
          [
            ["Upgrade", "WebSocket"],
            ["Connection", "Upgrade"],
            ["WebSocket-Origin", @headers['origin']],
            ["WebSocket-Location", handshake_location]
          ]
        end

      end
    end
  end
end
