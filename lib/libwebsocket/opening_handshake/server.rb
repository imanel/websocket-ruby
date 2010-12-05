module LibWebSocket
  class OpeningHandshake
    # Construct or parse a server WebSocket handshake. This module is written for
    # convenience, since using request and response directly requires the same code
    # again and again.
    #
    # SYNOPSIS
    #
    #   h = LibWebSocket::OpeningHandshake::Server.new
    #
    #   # Parse client request
    #   h.parse \<<EOF
    #   GET /demo HTTP/1.1
    #   Upgrade: WebSocket
    #   Connection: Upgrade
    #   Host: example.com
    #   Origin: http://example.com
    #   Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8
    #   Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0
    #
    #   Tm[K T2u
    #   EOF
    #
    #   h.error  # Check if there were any errors
    #   h.idone? # Returns true
    #
    #   # Create response
    #   h.to_s # HTTP/1.1 101 WebSocket Protocol Handshake
    #          # Upgrade: WebSocket
    #          # Connection: Upgrade
    #          # Sec-WebSocket-Origin: http://example.com
    #          # Sec-WebSocket-Location: ws://example.com/demo
    #          #
    #          # fQJ,fN/4F4!~K~MH
    class Server < OpeningHandshake

      # Parse client request
      # @example
      #   h.parse \<<EOF
      #   GET /demo HTTP/1.1
      #   Upgrade: WebSocket
      #   Connection: Upgrade
      #   Host: example.com
      #   Origin: http://example.com
      #   Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8
      #   Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0
      #
      #   Tm[K T2u
      #   EOF
      def parse(opts)
        req = self.req
        res = self.res

        unless req.done?
          unless req.parse(opts)
            self.error = req.error
            return
          end

          if req.done?
            res.version = req.version
            res.host = req.host

            # res.secure = req.secure
            res.resource_name = req.resource_name
            res.origin = req.origin

            if req.version > 75
              res.number1 = req.number1
              res.number2 = req.number2
              res.challenge = req.challenge
            end
          end
        end

        return true
      end

      # Check if request is correct and done
      def done?
        req.done?
      end

      # Create response in string format
      # @example
      #   h.to_s # HTTP/1.1 101 WebSocket Protocol Handshake
      #          # Upgrade: WebSocket
      #          # Connection: Upgrade
      #          # Sec-WebSocket-Origin: http://example.com
      #          # Sec-WebSocket-Location: ws://example.com/demo
      #          #
      #          # fQJ,fN/4F4!~K~MH
      def to_s
        res.to_s
      end

      # Create response in rack format
      # @example
      #   h.to_rack # [ 101,
      #             # {
      #             #   'Upgrade'                => 'WebSocket'
      #             #   'Connection'             => 'Upgrade'
      #             #   'Sec-WebSocket-Origin'   => 'http://example.com'
      #             #   'Sec-WebSocket-Location' => 'ws://example.com/demo'
      #             #   'Content-Length'         => 16
      #             # },
      #             # [ 'fQJ,fN/4F4!~K~MH' ] ]
      def to_rack
        res.to_rack
      end

    end
  end
end
