# frozen_string_literal: true

require 'digest/md5'

module WebSocket
  module Handshake
    module Handler
      # Client handshake for hybi drafts 01-03, which reuse the hixie-76 challenge/response
      # but add a numeric Sec-WebSocket-Draft header.
      class Client01 < Client76
        private

        # @see WebSocket::Handshake::Handler::Base#handshake_keys
        def handshake_keys
          keys = super
          keys << ['Sec-WebSocket-Draft', @handshake.version]
          keys
        end
      end
    end
  end
end
