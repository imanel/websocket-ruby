# encoding: binary

module WebSocket
  module Frame
    module Handler
      module Handler05

        include Handler04

        private

        # Since handler 5 masking should be enabled by default
        def masking?; true; end

      end
    end
  end
end
