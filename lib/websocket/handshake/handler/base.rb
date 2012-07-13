module WebSocket
  module Handshake
    module Handler
      module Base

        def to_s
          result = [ header_line ]
          handshake_keys.each do |key|
            result << key.join(': ')
          end
          result << ""
          result << finishing_line
          result.join("\r\n")
        end

        private

        def finishing_line
          ""
        end

      end
    end
  end
end
