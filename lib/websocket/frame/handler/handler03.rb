# encoding: binary

module WebSocket
  module Frame
    module Handler
      module Handler03

        include Base

        def encode_frame
          frame = ''

          opcode = type_to_opcode(@type)
          byte1 = opcode # since more, rsv1-3 are 0
          frame << byte1

          length = @data.size
          if length <= 125
            byte2 = length # since rsv4 is 0
            frame << byte2
          elsif length < 65536 # write 2 byte length
            frame << 126
            frame << [length].pack('n')
          else # write 8 byte length
            frame << 127
            frame << [length >> 32, length & 0xFFFFFFFF].pack("NN")
          end

          frame << @data
          frame
        end

        def decode_frame
        end

        private

        def supported_frames
          [:text, :binary, :close, :ping, :pong]
        end

        FRAME_TYPES = {
          :continuation => 0,
          :close => 1,
          :ping => 2,
          :pong => 3,
          :text => 4,
          :binary => 5
        }

        def type_to_opcode(frame_type)
          FRAME_TYPES[frame_type] || raise(WebSocket::Error, :unknown_frame_type)
        end

      end
    end
  end
end
