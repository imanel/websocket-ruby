module WebSocket
  module Handshake
    module Handler
      module Server75

        include Server

        private

        def handshake_keys
          [
            ["Upgrade", "WebSocket"],
            ["Connection", "Upgrade"],
            ["WebSocket-Origin", @headers['origin']],
            ["WebSocket-Location", handshake_location]
          ]
        end

        def handshake_location
          location = @host.to_s
          location << ":#{@port}" if @port
          location << @path
          location << "?#{@query}" if @query
        end

      end
    end
  end
end
