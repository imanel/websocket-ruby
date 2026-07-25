# frozen_string_literal: true

module WebSocket
  module Frame
    class Incoming
      # Frames received by a server from a client.
      class Server < Incoming
        # Whether the client is expected to mask the frames it sends, as required
        # for masking-capable protocol drafts.
        # @return [Boolean]
        def incoming_masking?
          @handler.masking?
        end

        # Per RFC 6455, frames sent from a server to a client must never be masked.
        # @return [Boolean] false
        def outgoing_masking?
          false
        end
      end
    end
  end
end
