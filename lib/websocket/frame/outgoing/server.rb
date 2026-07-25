# frozen_string_literal: true

module WebSocket
  module Frame
    class Outgoing
      # Frames sent by a server to a client.
      class Server < Outgoing
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
