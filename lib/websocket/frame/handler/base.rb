module WebSocket
  module Frame
    module Handler
      module Base

        MAX_FRAME_SIZE = 10 * 1024 * 1024 # 10MB

        # Is selected type supported for selected handler?
        def support_type?
          supported_frames.include?(@type)
        end

        # Implement in submodules
        def supported_frames
          raise NotImplementedError
        end

        private

        # Convert data to raw frame ready to send to client
        def encode_frame
          raise NotImplementedError
        end

        # Convert raw data to decoded frame
        def decode_frame
          raise NotImplementedError
        end

        # Required for support of Ruby 1.8
        def getbyte(data, byte)
          if data.respond_to?(:getbyte)
            data.getbyte(byte)
          else
            data[byte]
          end
        end

      end
    end
  end
end
