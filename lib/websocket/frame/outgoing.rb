module WebSocket
  module Frame
    class Outgoing < Base

      # Is selected type supported by current draft version?
      # @return [Boolean] true if frame type is supported
      def supported?
        support_type?
      end

      # Should current frame be sent? Exclude empty frames etc.
      # @return [Boolean] true if frame should be sent
      def require_sending?
        !(error? || @data.empty? && [:text, :binary].include?(@type))
      end

      # Return raw frame formatted for sending.
      def to_s
        set_error(:unknown_frame_type) and return unless supported?
        encode_frame
      end

    end
  end
end
