module WebSocket
  module Frame
    class Outgoing < Base

      autoload :Client, "#{::WebSocket::ROOT}/websocket/frame/outgoing/client"
      autoload :Server, "#{::WebSocket::ROOT}/websocket/frame/outgoing/server"

      # Is selected type supported by current draft version?
      # @return [Boolean] true if frame type is supported
      def supported?
        support_type?
      end

      # Should current frame be sent? Exclude empty frames etc.
      # @return [Boolean] true if frame should be sent
      def require_sending?
        !error?
      end

      # Return raw frame formatted for sending.
      def to_s
        set_error(:unknown_frame_type) and return unless supported?
        encode_frame
      end

    end
  end
end
