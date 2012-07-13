module WebSocket
  module Handshake
    module Handler
      module Server

        include Base

        def host
          @headers["host"].to_s.split(":")[0].to_s
        end

        def port
          @headers["host"].to_s.split(":")[1]
        end

        private

        def handshake_location
          location = @secure ? "wss://" : "ws://"
          location << host
          location << ":#{port}" if port
          location << path
          location << "?#{@query}" if @query
          location
        end

      end
    end
  end
end
