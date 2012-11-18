module WebSocket
  module Handshake
    class Client < Base

      def initialize(args = {})
        super

        @version = args[:version] || DEFAULT_VERSION
        @origin = args[:origin]

        if args[:uri]
          uri     = URI.parse(args[:uri])
          @secure = (uri.scheme == 'wss')
          @host   = uri.host
          @port   = uri.port
          @path   = uri.path
          @query  = uri.query
        end

        @secure = args[:secure] if args[:secure]
        @host   = args[:host]   if args[:host]
        @port   = args[:port]   if args[:port]
        @path   = args[:path]   if args[:path]
        @query  = args[:query]  if args[:query]

        @path   ||= '/'

        set_error(:no_host_provided) unless @host

        include_version
      end

      def <<(data)
        @data << data
        if parse_data

        end
      end

      def should_respond?
        false
      end

      def uri
        uri = @secure ? "wss://" : "ws://"
        uri << @host
        uri << ":#{@port}" if @port
        uri << @path
        uri << "?#{@query}" if @query
        uri
      end

      private

      def include_version
        case @version
          when 75 then extend Handler::Client75
          when 76, 0..3 then extend Handler::Client76
          # when 4..13 then extend Handler::Client04
          else set_error(:unknown_protocol_version) and return false
        end
        return true
      end

      FIRST_LINE = /^HTTP\/1\.1 (\d{3})[\w\s]*$/

      def parse_first_line(line)
        line_parts = line.match(FIRST_LINE)
        status = line_parts[1]
        set_error(:invalid_status_code) and return unless status == '101'

        return true
      end

    end
  end
end
