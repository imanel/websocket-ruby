module WebSocket
  module Handshake
    module Handler
      module Client

        include Base

        private

        def header_line
          "GET #{@path} HTTP/1.1"
        end

      end
    end
  end
end
