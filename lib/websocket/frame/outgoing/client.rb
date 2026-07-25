# frozen_string_literal: true

module WebSocket
  module Frame
    class Outgoing
      # Frames sent by a client to a server.
      class Client < Outgoing
        # Per RFC 6455, frames sent from a server to a client must never be masked.
        # @return [Boolean] false
        def incoming_masking?
          false
        end

        # Whether this client must mask the frames it sends to the server, as required
        # for masking-capable protocol drafts.
        # @return [Boolean]
        def outgoing_masking?
          @handler.masking?
        end
      end
    end
  end
end
