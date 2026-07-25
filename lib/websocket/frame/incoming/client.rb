# frozen_string_literal: true

module WebSocket
  module Frame
    class Incoming
      # Frames received by a client from a server.
      class Client < Incoming
        # Per RFC 6455, frames sent from a server to a client must never be masked.
        # @return [Boolean] false
        def incoming_masking?
          false
        end

        # Whether this client masks the frames it sends to the server, as required
        # for masking-capable protocol drafts.
        # @return [Boolean]
        def outgoing_masking?
          @handler.masking?
        end
      end
    end
  end
end
