module WebSocket
  module Frame
    class Outgoing < Base

      # Is selected type supported by current draft version?
      # @return [Boolean] true if frame type is supported
      def supported?
        handler.support?(@type)
      end

      # Return raw frame formatted for sending.
      def to_s
        handler.encode_frame(@data, :type => @type)
      end

    end
  end
end
