# frozen_string_literal: true

module WebSocket
  # Base class for all errors raised by this library. Every error's #message
  # returns a Symbol (rather than a String) describing the failure, which is
  # also the value exposed via `error` on frames and handshakes when
  # {WebSocket.should_raise} is false.
  class Error < RuntimeError
    # Errors raised while encoding or decoding a {WebSocket::Frame}.
    class Frame < ::WebSocket::Error
      # A control frame (close/ping/pong) declared a payload larger than the
      # 125-byte limit imposed by the spec.
      class ControlFramePayloadTooLong < ::WebSocket::Error::Frame
        def message
          :control_frame_payload_too_long
        end
      end

      # A text or binary frame was received while a previous fragmented
      # message was still awaiting its continuation frame.
      class DataFrameInsteadContinuation < ::WebSocket::Error::Frame
        def message
          :data_frame_instead_continuation
        end
      end

      # A control frame (close/ping/pong) was sent as a fragment, which the
      # spec forbids - control frames must never be fragmented.
      class FragmentedControlFrame < ::WebSocket::Error::Frame
        def message
          :fragmented_control_frame
        end
      end

      # A hixie-75 draft frame did not match the expected `\x00...\xff` framing.
      class Invalid < ::WebSocket::Error::Frame
        def message
          :invalid_frame
        end
      end

      # A text frame's payload (or the concatenated payload of a fragmented
      # message) was not valid UTF-8.
      class InvalidPayloadEncoding < ::WebSocket::Error::Frame
        def message
          :invalid_payload_encoding
        end
      end

      # A masked frame's payload was shorter than the 4-byte masking key.
      class MaskTooShort < ::WebSocket::Error::Frame
        def message
          :mask_is_too_short
        end
      end

      # A frame used one of the reserved RSV bits, which is only permitted
      # when negotiated via an extension this library does not implement.
      class ReservedBitUsed < ::WebSocket::Error::Frame
        def message
          :reserved_bit_used
        end
      end

      # A frame declared a payload length larger than {WebSocket.max_frame_size}.
      class TooLong < ::WebSocket::Error::Frame
        def message
          :frame_too_long
        end
      end

      # A continuation frame was received without a preceding fragmented
      # (more-bit/fin-bit) frame to continue.
      class UnexpectedContinuationFrame < ::WebSocket::Error::Frame
        def message
          :unexpected_continuation_frame
        end
      end

      # A frame's opcode did not map to any frame type known by the handler.
      class UnknownFrameType < ::WebSocket::Error::Frame
        def message
          :unknown_frame_type
        end
      end

      # A frame's opcode byte did not match any opcode known by the handler.
      class UnknownOpcode < ::WebSocket::Error::Frame
        def message
          :unknown_opcode
        end
      end

      # A close frame carried a status code outside the ranges permitted by the spec.
      class UnknownCloseCode < ::WebSocket::Error::Frame
        def message
          :unknown_close_code
        end
      end

      # A frame was constructed with a protocol version not supported by this library.
      class UnknownVersion < ::WebSocket::Error::Frame
        def message
          :unknown_protocol_version
        end
      end
    end

    # Errors raised while constructing or parsing a {WebSocket::Handshake}.
    class Handshake < ::WebSocket::Error
      # A server received a request whose method was not GET.
      class GetRequestRequired < ::WebSocket::Error::Handshake
        def message
          :get_request_required
        end
      end

      # The handshake's authentication challenge (Sec-WebSocket-Accept, hixie-76
      # challenge response, etc.) did not match the expected value.
      class InvalidAuthentication < ::WebSocket::Error::Handshake
        def message
          :invalid_handshake_authentication
        end
      end

      # The request/response's first line (request line or status line) could not be parsed.
      class InvalidHeader < ::WebSocket::Error::Handshake
        def message
          :invalid_header
        end
      end

      # None of the client's requested sub-protocols were supported by the server, or
      # vice versa.
      class UnsupportedProtocol < ::WebSocket::Error::Handshake
        def message
          :unsupported_protocol
        end
      end

      # A client received a response whose HTTP status code was not 101 (Switching Protocols).
      class InvalidStatusCode < ::WebSocket::Error::Handshake
        def message
          :invalid_status_code
        end
      end

      # A client handshake was constructed without a :host, :url or :uri option.
      class NoHostProvided < ::WebSocket::Error::Handshake
        def message
          :no_host_provided
        end
      end

      # A handshake was constructed, or detected, with a protocol version not
      # supported by this library.
      class UnknownVersion < ::WebSocket::Error::Handshake
        def message
          :unknown_protocol_version
        end
      end
    end
  end
end
