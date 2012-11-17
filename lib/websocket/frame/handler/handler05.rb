# encoding: binary

module WebSocket
  module Frame
    module Handler
      module Handler05

        include Handler04

        private

        def masking?; true; end

      end
    end
  end
end
