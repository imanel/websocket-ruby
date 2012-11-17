module WebSocket
  module Frame
    class Data < String

      def initialize(*args)
        super *args.each { |arg| arg.force_encoding('ASCII-8BIT') if respond_to?(:force_encoding) }
      end

      def <<(*args)
        super *args.each { |arg| arg.force_encoding('ASCII-8BIT') if respond_to?(:force_encoding) }
      end

      def set_mask
        raise "Too short" if bytesize < 4 # TODO - change
        @masking_key = Data.new(self[0..3])
      end

      def unset_mask
        @masking_key = nil
      end

      def getbytes(start_index, count)
        data = ''
        data.force_encoding('ASCII-8BIT') if data.respond_to?(:force_encoding)
        count.times do |i|
          data << getbyte(start_index + i)
        end
        data
      end

      # Required for support of Ruby 1.8
      unless new.respond_to?(:getbyte)
        def getbyte(index)
          self[index]
        end
      end

      def getbyte_with_masking(index)
        if @masking_key
          masked_char = getbyte_without_masking(index)
          masked_char ? masked_char ^ @masking_key.getbyte(index % 4) : nil
        else
          getbyte_without_masking(index)
        end
      end

      alias_method :getbyte_without_masking, :getbyte
      alias_method :getbyte, :getbyte_with_masking

    end
  end
end
