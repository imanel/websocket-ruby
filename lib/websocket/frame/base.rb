module WebSocket
  module Frame
    class Base
      DEFAULT_VERSION = 13

      attr_reader :data, :type, :version

      # Initialize frame
      # @param args [Hash] Arguments for frame
      # @option args [Integer] :version Version of draft. Currently supported version are 75, 76 and 00-13.
      # @option args [String] :type Type of frame - available types are "text", "binary", "ping", "pong" and "close"(support depends on draft version)
      # @option args [String] :data default data for frame
      def initialize(args = {})
        @version = args[:version] || DEFAULT_VERSION
        @type = args[:type]
        @data = args[:data] || ""
      end

      # Should current frame be sent? Exclude empty frames etc.
      # @return [Boolean] true if frame should be sent
      def require_sending?
        raise NotImplementedError
      end

      private

      def handler
        @handler ||= case @version
          when 75..76 then extend Handler::Handler75
          when 0..2 then extend Handler::Handler75
          # Not implemented yet
          # when 3 then extend Handler::Handler03
          # when 4 then extend Handler::Handler04
          # when 5 then extend Handler::Handler05
          # when 7 then extend Handler::Handler07
          else set_error('Unknown version') and return false
        end
      end

    end
  end
end
