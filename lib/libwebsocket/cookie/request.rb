module LibWebSocket
  class Cookie
    # Construct or parse a WebSocket request cookie.
    class Request < Cookie

      attr_accessor :name, :value, :version, :path, :domain

      # Parse a WebSocket request cookie.
      # @example
      #   cookie = LibWebSocket::Cookie::Request.new
      #   cookies = cookie.parse('$Version=1; foo="bar"; $Path=/; bar=baz; $Domain=.example.com')
      def parse(string)
        result = super
        return unless result

        cookies = []

        pair = self.pairs.shift
        version = pair[1]

        cookie = nil
        self.pairs.each do |pair|
          next if pair[0].nil?

          if pair[0].match(/^[^\$]/)
            cookies.push(cookie) unless cookie.nil?

            cookie = self.build_cookie( :name => pair[0], :value => pair[1], :version => version)
          elsif pair[0] == '$Path'
            cookie.path = pair[1]
          elsif pair[0] == '$Domain'
            cookie.domain = pair[1]
          end
        end

        cookies.push(cookie) unless cookie.nil?

        return cookies
      end

      protected

      def build_cookie(hash)
        self.class.new(hash)
      end
    end
  end
end
