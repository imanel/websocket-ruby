module WebSocket
  module Handshake
    class Server < Base

      def <<(data)
        @data << data
        if parse_data
          set_version
        end
      end

      def should_respond?
        true
      end

      private

      # TODO: Add support for #75 & #76
      def set_version
        @version = @headers['sec-websocket-version'].to_i
        include_version
      end

      PATH = /^(\w+) (\/[^\s]*) HTTP\/1\.1$/

      def parse_first_line(line)
        line_parts = line.match(PATH)
        method = line_parts[1].strip
        set_error("Must be GET request") and return unless method == "GET"

        resource_name = line_parts[2].strip
        path, query = resource_name.split('?', 2)

        return true
      end

    end
  end
end
