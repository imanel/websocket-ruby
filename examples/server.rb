require "#{File.expand_path(File.dirname(__FILE__))}/base"

# Example WebSocket Server (using EventMachine)
# @example
#   WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => 8080) do |ws|
#     ws.onopen    { ws.send "Hello Client!"}
#     ws.onmessage { |msg| ws.send "Pong: #{msg}" }
#     ws.onclose   { puts "WebSocket closed" }
#     ws.onerror   { |e| puts "Error: #{e}" }
#   end
module WebSocket
  module EventMachine
    class Server < Base

      # Start server
      # @param options [Hash] The request arguments
      # @option args [String] :host The host IP/DNS name
      # @option args [Integer] :port The port to connect too(default = 80)
      def self.start(options, &block)
        ::EventMachine::start_server(options[:host], options[:port], self, options) do |c|
          block.call(c)
        end
      end

      # Initialize connection
      # @param args [Hash] Arguments for server
      # @option args [Boolean] :secure If true then server will run over SSL
      # @option args [Hash] :tls_options Options for SSL if secure = true
      def initialize(args)
        @secure = args[:secure] || false
        @tls_options = args[:tls_options] || {}
      end

      ############################
      ### Eventmachine methods ###
      ############################

      def post_init
        @state = :connecting
        @handshake = WebSocket::Handshake::Server.new(:secure => @secure)
        start_tls(@tls_options) if @secure
      end

      private

      def incoming_frame
        WebSocket::Frame::Incoming::Server
      end

      def outgoing_frame
        WebSocket::Frame::Outgoing::Server
      end

    end
  end
end
