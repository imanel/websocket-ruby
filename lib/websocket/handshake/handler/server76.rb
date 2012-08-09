require 'digest/md5'

module WebSocket
  module Handshake
    module Handler
      module Server76

        include Server

        private

        def header_line
          "HTTP/1.1 101 WebSocket Protocol Handshake"
        end

        def handshake_keys
          [
            ["Upgrade", "WebSocket"],
            ["Connection", "Upgrade"],
            ["Sec-WebSocket-Origin", @headers['origin']],
            ["Sec-WebSocket-Location", handshake_location]
          ]
        end

        def finishing_line
          @finishing_line ||= challenge_response
        end

        def valid?
          super && !!finishing_line
        end

        private

        def challenge_response
          # Refer to 5.2 4-9 of the draft 76
          first = numbers_over_spaces(@headers['sec-websocket-key1']) || return
          second = numbers_over_spaces(@headers['sec-websocket-key2']) || return
          third = @leftovers.strip

          sum = [first].pack("N*") +
                [second].pack("N*") +
                third
          Digest::MD5.digest(sum)
        end

        def numbers_over_spaces(string)
          numbers = string.scan(/[0-9]/).join.to_i

          spaces = string.scan(/ /).size
          # As per 5.2.5, abort the connection if spaces are zero.
          set_error("Websocket Key1 or Key2 does not contain spaces - this is a symptom of a cross-protocol attack") and return if spaces == 0

          # As per 5.2.6, abort if numbers is not an integral multiple of spaces
          set_error("Invalid Key #{string.inspect}") and return if numbers % spaces != 0

          quotient = numbers / spaces

          set_error("Challenge computation out of range for key") and return if quotient > 2**32-1

          return quotient
        end

      end
    end
  end
end
