# frozen_string_literal: true

module WebSocket
  module Handshake
    module Handler
      # Client handshake for hybi drafts 11-17 and RFC 6455. Identical to draft 04 except
      # the origin header is renamed from Sec-WebSocket-Origin to Origin.
      class Client11 < Client04
        private

        # @see WebSocket::Handshake::Handler::Base#handshake_keys
        def handshake_keys
          super.collect do |key_pair|
            if key_pair[0] == 'Sec-WebSocket-Origin'
              ['Origin', key_pair[1]]
            else
              key_pair
            end
          end
        end
      end
    end
  end
end
