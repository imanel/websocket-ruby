# encoding: binary
# frozen_string_literal: true

module WebSocket
  module Frame
    module Handler
      # Frame encoder/decoder for hybi drafts 05-06 of the protocol.
      class Handler05 < Handler04
        # Since handler 5 masking should be enabled by default
        # @return [Boolean] true
        def masking?
          true
        end
      end
    end
  end
end
