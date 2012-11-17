module WebSocket
  module Frame
    module Handler
      module Base

        MAX_FRAME_SIZE = 20 * 1024 * 1024 # 20MB

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

        def control_frame?(frame_type)
          ![:text, :binary, :continuation].include?(frame_type)
        end

        def data_frame?(frame_type)
          [:text, :binary].include?(frame_type)
        end

      end
    end
  end
end
