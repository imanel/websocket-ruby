module LibWebSocket
  class OpeningHandshake
    # Construct or parse a client WebSocket handshake. This module is written for
    # convenience, since using request and response directly requires the same code
    # again and again.
    #
    # SYNOPSIS
    #
    #   h = LibWebSocket::OpeningHandshake::Client.new(:url => 'ws://example.com')
    #
    #   # Create request
    #   h.to_s # GET /demo HTTP/1.1
    #          # Upgrade: WebSocket
    #          # Connection: Upgrade
    #          # Host: example.com
    #          # Origin: http://example.com
    #          # Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8
    #          # Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0
    #          #
    #          # Tm[K T2u
    #
    #   # Parse server response
    #   h.parse \<<EOF
    #   HTTP/1.1 101 WebSocket Protocol Handshake
    #   Upgrade: WebSocket
    #   Connection: Upgrade
    #   Sec-WebSocket-Origin: http://example.com
    #   Sec-WebSocket-Location: ws://example.com/demo
    #
    #   fQJ,fN/4F4!~K~MH
    #   EOF
    #
    #   h.error # Check if there were any errors
    #   h.done? # Returns true
    class Client < OpeningHandshake

      attr_accessor :url

      def initialize(hash = {})
        super

        self.set_url(self.url) if self.url
      end

      # Set or get WebSocket url.
      # @see LibWebSocket::URL#initialize
      # @example
      #   handshake.url = 'ws://example.com/demo'
      def url=(val)
        self.set_url(val)

        return self
      end

      # Parse server response
      # @example
      #   h.parse \<<EOF
      #   HTTP/1.1 101 WebSocket Protocol Handshake
      #   Upgrade: WebSocket
      #   Connection: Upgrade
      #   Sec-WebSocket-Origin: http://example.com
      #   Sec-WebSocket-Location: ws://example.com/demo
      #
      #   fQJ,fN/4F4!~K~MH
      #   EOF
      def parse(opts)
        req = self.req
        res = self.res

        unless res.done?
          unless res.parse(opts)
            self.error = res.error
            return
          end

          if res.done?
            if req.version > 75 && req.checksum != res.checksum
              self.error = 'Checksum is wrong.'
              return
            end
          end
        end

        return true
      end

      # Check if response is correct
      def done?
        res.done?
      end

      # Create request
      # @example
      #   h.to_s # GET /demo HTTP/1.1
      #          # Upgrade: WebSocket
      #          # Connection: Upgrade
      #          # Host: example.com
      #          # Origin: http://example.com
      #          # Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8
      #          # Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0
      #          #
      #          # Tm[K T2u
      def to_s
        req.to_s
      end

      protected

      def build_url
        LibWebSocket::URL.new
      end

      def set_url(url)
        @url = self.build_url.parse(url) unless url.is_a?(LibWebSocket::URL)

        req = self.req

        host = @url.host
        host += ':' + @url.port if @url.port
        req.host = host

        req.resource_name = @url.resource_name

        return self
      end

    end
  end
end
