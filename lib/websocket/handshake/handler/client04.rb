require 'digest/sha1'
require 'base64'

module WebSocket
  module Handshake
    module Handler
      module Client04

        include Client

        def valid?
          super && verify_accept
        end

        private

        def handshake_keys
          keys = [
            ["Upgrade", "websocket"],
            ["Connection", "Upgrade"]
          ]
          host = @host
          host += ":#{@port}" if @port
          keys << ["Host", host]
          keys << ["Sec-WebSocket-Origin", @origin] if @origin
          keys << ["Sec-WebSocket-Version", @version]
          keys << ["Sec-WebSocket-Key", key]
          keys
        end

        def key
          @key ||= Base64.encode64((1..16).map { rand(255).chr } * '').strip
        end

        def accept
          @accept ||= Base64.encode64(Digest::SHA1.digest(key + '258EAFA5-E914-47DA-95CA-C5AB0DC85B11')).strip
        end

        def verify_accept
          set_error(:invalid_accept) and return false unless @headers['sec-websocket-accept'] == accept
          true
        end

      end
    end
  end
end
