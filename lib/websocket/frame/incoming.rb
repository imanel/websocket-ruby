module WebSocket
  module Frame
    class Incoming < Base

      def initialize(args = {})
        @decoded = args[:decoded] || false
        super
      end

      # If data is still encoded after receiving then this is false. After calling "next" you will receive
      # another instance of incoming frame, but with data decoded - this function will return true and
      # to_s will return frame content instead of raw data.
      # @return [Boolean] If frame already decoded?
      def decoded?
        @decoded
      end

      # Add provided string as raw incoming frame.
      # @param data [String] Raw frame
      def <<(data)
        @data << data
      end

      # Return next complete frame.
      # This function will merge together splitted frames and return as combined content.
      # Check #error if nil received to check for eventual parsing errors
      # @return [WebSocket::Frame::Incoming] Single incoming frame or nil if no complete frame is available.
      def next
        decode_frame unless decoded?
      end

      # If decoded then this will return frame content. Otherwise it will return raw frame.
      # @return [String] Data of frame
      def to_s
        @data
      end

    end
  end
end
