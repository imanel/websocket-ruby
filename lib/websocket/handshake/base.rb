module WebSocket
  module Handshake
    class Base

      attr_reader :host, :port, :path, :query,
                  :error, :state, :version, :secure

      def initialize(args = {})
        @state = :new

        @data = ""
        @headers = {}
      end

      def <<(data)
        raise NotImplementedError
      end

      def finished?
        @state == :finished || @state == :error
      end

      def valid?
        finished? && @error == nil
      end

      def should_respond?
        raise NotImplementedError
      end

      def leftovers
        @leftovers.split("\n", reserved_leftover_lines + 1)[reserved_leftover_lines]
      end

      private

      def reserved_leftover_lines
        0
      end

      def set_error(message)
        @state = :error
        @error = message
      end

      HEADER = /^([^:]+):\s*(.+)$/

      def parse_data
        header, @leftovers = @data.split("\r\n\r\n", 2)
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
