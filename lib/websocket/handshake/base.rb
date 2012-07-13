module WebSocket
  module Handshake
    class Base

      attr_reader :host, :port, :path, :query,
                  :error, :state, :version

      def initialize(args = {})
        @state = :new

        @data = ""
        @headers = {}
      end

      def <<(data)
        raise NotImplementedError
      end

      def finished?
        @state == :finished
      end

      def valid?
        finished? && @error == nil
      end

      def should_respond?
        raise NotImplementedError
      end

      private

      def set_error(message)
        @state = :error
        @error = message
      end

      def include_version
        case @version
          when 13 then include Handler::Handler13
          else set_error('Unknown version') and return false
        end
        return true
      end

      HEADER = /^([^:]+):\s*(.+)$/

      def parse_data
        header, @leftovers = data.split("\r\n\r\n", 2)
        return unless @leftovers # The whole header has not been received yet.

        lines = header.split("\r\n")

        first_line = lines.shift
        return unless parse_first_line(first_line)

        lines.each do |line|
          h = HEADER.match(line)
          @headers[h[1].strip.downcase] = h[2].strip if h
        end

        @state = :finished
      end

    end
  end
end
