module WebSocket
  module Frame
    # @abstract Subclass and override to implement custom frames
    class Base
      include Common

      attr_reader :type
      attr_accessor :data, :code

      VERSION_MAP = {
        75..76 => "75",
        0..2   => "75",
        [3]    => "03",
        [4]    => "04",
        5..6   => "05",
        7..13  => "07"
      }

      # Initialize frame
      # @param args [Hash] Arguments for frame
      # @option args [String]  :data default data for frame
      # @option args [String]  :type Type of frame - available types are "text", "binary", "ping", "pong" and "close"(support depends on draft version)
      # @option args [Integer] :code Code for close frame. Supported by drafts > 05.
      # @option args [Integer] :version Version of draft. Currently supported version are 75, 76 and 00-13.
      def initialize(args = {})
        @type = args[:type].to_sym if args[:type]
        @code = args[:code]
        @data = Data.new(args[:data].to_s)
        @version = args[:version] || DEFAULT_VERSION
        @handler = nil
        include_version(:Frame, :Handler)
      end
      rescue_method :initialize

      # Check if some errors occured
      # @return [Boolean] True if error is set
      def error?
        !!@error
      end

      # Is selected type supported for selected handler?
      def support_type?
        @handler.supported_frames.include?(@type)
      end

      # Implement in submodules
      def supported_frames
        raise NotImplementedError
      end

    end
  end
end
