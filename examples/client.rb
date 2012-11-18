require "#{File.expand_path(File.dirname(__FILE__))}/base"
require 'uri'

# Example WebSocket Client (using EventMachine)
# @example
#   ws = WebSocket::EventMachine::Client.connect(:host => "0.0.0.0", :port => 8080)
#   ws.onmessage { |msg| ws.send "Pong: #{msg}" }
#   ws.send "data"
module WebSocket
  module EventMachine
    class Client < Base

      # Connect to websocket server
      # @param args [Hash] The request arguments
      # @option args [String] :host The host IP/DNS name
      # @option args [Integer] :port The port to connect too(default = 80)
      # @option args [Integer] :version Version of protocol to use(default = 13)
      def self.connect(args = {})
        host = nil
        port = nil
        if args[:uri]
          uri = URI.parse(args[:uri])
          host = uri.host
          port = uri.port
        end
        host = args[:host] if args[:host]
        port = args[:port] if args[:port]
        port ||= 80

        ::EventMachine.connect host, port, self, args
      end

      # Initialize connection
      # @param args [Hash] Arguments for connection
      # @option args [String] :host The host IP/DNS name
      # @option args [Integer] :port The port to connect too(default = 80)
      # @option args [Integer] :version Version of protocol to use(default = 13)
      def initialize(args)
        @args = args
      end

      ############################
      ### EventMachine methods ###
      ############################

      # Called after initialize of connection, but before connecting to server
      def post_init
        @state = :connecting
        @handshake = WebSocket::Handshake::Client.new(@args)
      end

      # Called by EventMachine after connecting.
      # Sends handshake to server
      def connection_completed
        send(@handshake.to_s, :type => :plain)
      end

      private

      def incoming_frame
        WebSocket::Frame::Incoming::Client
      end

      def outgoing_frame
        WebSocket::Frame::Outgoing::Client
      end

    end
  end
end
