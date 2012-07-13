require 'digest/sha1'
require 'base64'

module WebSocket
  module Handshake
    module Handler
      module Server04

        include Server

        private

        def handshake_specific_keys
          [
            ["Sec-WebSocket-Accept", signature]
          ]
        end

        def signature
          set_error("Sec-WebSocket-Key header is required") and return unless key = @headers['sec-websocket-key']
          string_to_sign = "#{key}258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
          Base64.encode64(Digest::SHA1.digest(string_to_sign)).chomp
        end

      end
    end
  end
end
