# encoding: binary
# frozen_string_literal: true

module WebSocket
  module Frame
    module Handler
      # Frame encoder/decoder for hybi drafts 07-13 of the protocol and RFC 6455.
      # Adds close frame status codes and validates that text frame payloads
      # (including the concatenated result of continuation frames) are valid UTF-8.
      class Handler07 < Handler05
        # Hash of frame names and it's opcodes
        FRAME_TYPES = {
          continuation: 0,
          text: 1,
          binary: 2,
          close: 8,
          ping: 9,
          pong: 10
        }.freeze

        # Hash of frame opcodes and it's names
        FRAME_TYPES_INVERSE = FRAME_TYPES.invert.freeze

        # @see WebSocket::Frame::Handler::Base#encode_frame
        # @raise [WebSocket::Error::Frame::UnknownCloseCode] if a close frame carries an invalid status code
        def encode_frame
          if @frame.type == :close
            code = @frame.code || 1000
            raise WebSocket::Error::Frame::UnknownCloseCode unless valid_code?(code)

            @frame.data = Data.new([code].pack('n') + @frame.data.to_s)
            @frame.code = nil
          end
          super
        end

        # @see WebSocket::Frame::Handler::Base#decode_frame
        # @raise [WebSocket::Error::Frame::UnknownCloseCode] if a close frame carries an invalid status code
        # @raise [WebSocket::Error::Frame::InvalidPayloadEncoding] if a close frame's message is not valid UTF-8
        def decode_frame
          result = super
          if close_code?(result)
            code = result.data.slice!(0..1)
            result.code = code.unpack('n').first
            raise WebSocket::Error::Frame::UnknownCloseCode unless valid_code?(result.code)
            raise WebSocket::Error::Frame::InvalidPayloadEncoding unless valid_encoding?(result.data)
          end
          result
        end

        private

        # Check if the given close code is one of the codes reserved by the spec, or in the
        # range available for application use (3000-4999).
        # @param [Integer] code Close status code
        # @return [Boolean] true if code is valid
        def valid_code?(code)
          [1000, 1001, 1002, 1003, 1007, 1008, 1009, 1010, 1011].include?(code) || (3000..4999).cover?(code)
        end

        # @param [String, nil] data Data to validate
        # @return [Boolean] true if data is nil or valid UTF-8
        def valid_encoding?(data)
          return true if data.nil?

          data.encode('UTF-8')
          true
        rescue StandardError
          false
        end

        # @param [WebSocket::Frame::Incoming, nil] frame Decoded frame to check
        # @return [Boolean] true if frame is a close frame carrying a status code
        def close_code?(frame)
          frame && frame.type == :close && !frame.data.empty?
        end

        # Convert frame type name to opcode
        # @param [Symbol] frame_type Frame type name
        # @return [Integer] opcode or nil
        # @raise [WebSocket::Error] if frame opcode is not known
        def type_to_opcode(frame_type)
          FRAME_TYPES[frame_type] || raise(WebSocket::Error::Frame::UnknownFrameType)
        end

        # Convert frame opcode to type name
        # @param [Integer] opcode Opcode
        # @return [Symbol] Frame type name or nil
        # @raise [WebSocket::Error] if frame type name is not known
        def opcode_to_type(opcode)
          FRAME_TYPES_INVERSE[opcode] || raise(WebSocket::Error::Frame::UnknownOpcode)
        end
      end
    end
  end
end
