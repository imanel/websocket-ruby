module WebSocket
  class Error < RuntimeError

    module Frame

      class ControlFramePayloadTooLong < ::WebSocket::Error;
        def message; :control_frame_payload_too_long; end
      end

      class DataFrameInsteadContinuation < ::WebSocket::Error;
        def message; :data_frame_instead_continuation; end
      end

      class FragmentedControlFrame < ::WebSocket::Error;
        def message; :fragmented_control_frame; end
      end

      class Invalid < ::WebSocket::Error;
        def message; :invalid_frame; end
      end

      class InvalidPayloadEncoding < ::WebSocket::Error;
        def message; :invalid_payload_encoding; end
      end

      class ReservedBitUsed < ::WebSocket::Error;
        def message; :reserved_bit_used; end
      end

      class TooLong < ::WebSocket::Error;
        def message; :frame_too_long; end
      end

      class UnexpectedContinuationFrame < ::WebSocket::Error;
        def message; :unexpected_continuation_frame; end
      end

      class UnknownFrameType < ::WebSocket::Error;
        def message; :unknown_frame_type; end
      end

      class UnknownOpcode < ::WebSocket::Error;
        def message; :unknown_opcode; end
      end

    end

  end
end
