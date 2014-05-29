module WebSocket
  module Frame
    class Data < String

      def initialize(*args)
        super(*convert_args(args))
      end

      def <<(*args)
        super(*convert_args(args))
      end

      def convert_args(args)
        args.each { |arg| arg.force_encoding('ASCII-8BIT') if arg.respond_to?(:force_encoding) }
      end

      def set_mask
        raise WebSocket::Error::Frame::MaskTooShort if bytesize < 4
        @masking_key = self[0..3].bytes.to_a
      end

      def unset_mask
        @masking_key = nil
      end

      def getbytes(start_index, count)
        data = self[start_index, count]
        data = mask(data.bytes.to_a, @masking_key).pack('C*') if @masking_key
        data
      end

      def mask(payload, mask)
        return mask_native(payload, mask) if respond_to?(:mask_native)
        result = []
        payload.each_with_index do |byte, i|
          result[i] = byte ^ mask[i % 4]
        end
        result
      end

    end
  end
end
