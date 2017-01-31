module WebSocket
  module Handshake
    module Handler
      class Client75 < Client
        # @see WebSocket::Handshake::Base#valid?
        def valid?
          super && verify_protocol
        end

        private

        # @see WebSocket::Handshake::Handler::Base#handshake_keys
        def handshake_keys
          keys = [
            %w(Upgrade WebSocket),
            %w(Connection Upgrade)
          ]
          host = @handshake.host
          host += ":#{@handshake.port}" if @handshake.port
          keys << ['Host', host]
          keys << ['Origin', @handshake.origin] if @handshake.origin
          keys << ['WebSocket-Protocol', @handshake.protocols.first] if @handshake.protocols.any?
          keys += super
          keys
        end

        # Verify if received header WebSocket-Protocol matches with the sent one
        # @return [Boolean] True if matching. False otherwise(appropriate error is set)
        def verify_protocol
          return true if @handshake.protocols.empty?
          invalid = @handshake.headers['websocket-protocol'].strip != @handshake.protocols.first
          raise WebSocket::Error::Handshake::UnsupportedProtocol if invalid
          true
        end
      end
    end
  end
end
