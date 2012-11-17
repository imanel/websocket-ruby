# encoding: binary

module WebSocket
  module Frame
    module Handler
      module Handler07

        include Handler05

        private

        FRAME_TYPES = {
          :continuation => 0,
          :text => 1,
          :binary => 2,
          :close => 8,
          :ping => 9,
          :pong => 10,
        }

        FRAME_TYPES_INVERSE = FRAME_TYPES.invert

        def type_to_opcode(frame_type)
          FRAME_TYPES[frame_type] || raise(WebSocket::Error, :unknown_frame_type)
        end

        def opcode_to_type(opcode)
          FRAME_TYPES_INVERSE[opcode] || raise(WebSocket::Error, :unknown_opcode)
        end

      end
    end
  end
end
