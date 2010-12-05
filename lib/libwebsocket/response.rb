module LibWebSocket
  #Construct or parse a WebSocket response.
  class Response < Message

    attr_accessor :location, :secure, :resource_name, :cookies, :key1, :key2

    # Parse a WebSocket response.
    # @see Message#parse
    # @example Parser
    #   res = LibWebSocket::Response.new;
    #   res.parse("HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a")
    #   res.parse("Upgrade: WebSocket\x0d\x0a")
    #   res.parse("Connection: Upgrade\x0d\x0a")
    #   res.parse("Sec-WebSocket-Origin: file://\x0d\x0a")
    #   res.parse("Sec-WebSocket-Location: ws://example.com/demo\x0d\x0a")
    #   res.parse("\x0d\x0a")
    #   res.parse("0st3Rl&q-2ZU^weu")
    def parse(string)
      super
    end

    # Construct a WebSocket response in string format.
    # @example Construct
    #   res = LibWebSocket::Response.new(
    #     :host          => 'example.com',
    #     :resource_name => '/demo',
    #     :origin        => 'file://',
    #     :number1       => 777_007_543,
    #     :number2       => 114_997_259,
    #     :challenge     => "\x47\x30\x22\x2D\x5A\x3F\x47\x58"
    #   )
    #   res.to_s # HTTP/1.1 101 WebSocket Protocol Handshake
    #            # Upgrade: WebSocket
    #            # Connection: Upgrade
    #            # Sec-WebSocket-Origin: file://
    #            # Sec-WebSocket-Location: ws://example.com/demo
    #            #
    #            # 0st3Rl&q-2ZU^weu
    def to_s
      string = ''

      string += "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a"

      string += "Upgrade: WebSocket\x0d\x0a"
      string += "Connection: Upgrade\x0d\x0a"

      raise 'host is required' unless self.host

      location = self.build_url(
          :host => self.host,
          :secure => self.secure,
          :resource_name => self.resource_name
      )
      origin = self.origin || 'http://' + location.host

      if self.version <= 75
          string += 'WebSocket-Protocol: ' + self.subprotocol + "\x0d\x0a" if self.subprotocol
          string += 'WebSocket-Origin: ' + origin + "\x0d\x0a"
          string += 'WebSocket-Location: ' + location.to_s + "\x0d\x0a"
      else
          string += 'Sec-WebSocket-Protocol: ' + self.subprotocol + "\x0d\x0a" if self.subprotocol
          string += 'Sec-WebSocket-Origin: ' + origin + "\x0d\x0a"
          string += 'Sec-WebSocket-Location: ' + location.to_s + "\x0d\x0a"
      end

      unless self.cookies.empty?
          string += 'Set-Cookie: '
          string += self.cookies.collect(&:to_s).join(',')
          string += "\x0d\x0a"
      end

      string += "\x0d\x0a"

      string += self.checksum if self.version > 75

      return string
    end

    # Construct a WebSocket response in rack format.
    # @example Construct
    #   res = LibWebSocket::Response.new(
    #     :host          => 'example.com',
    #     :resource_name => '/demo',
    #     :origin        => 'file://',
    #     :number1       => 777_007_543,
    #     :number2       => 114_997_259,
    #     :challenge     => "\x47\x30\x22\x2D\x5A\x3F\x47\x58"
    #   )
    #   res.to_rack # [ 101,
    #               # {
    #               #   'Upgrade'                => 'WebSocket'
    #               #   'Connection'             => 'Upgrade'
    #               #   'Sec-WebSocket-Origin'   => 'file://'
    #               #   'Sec-WebSocket-Location' => 'ws://example.com/demo'
    #               #   'Content-Length'         => 16
    #               # },
    #               # [ 0st3Rl&q-2ZU^weu ] ]
    def to_rack
      status = 101
      hash = {}
      body = ''

      hash = {'Upgrade' => 'WebSocket', 'Connection' => 'Upgrade'}

      raise 'host is required' unless self.host

      location = self.build_url(
          :host => self.host,
          :secure => self.secure,
          :resource_name => self.resource_name
      )
      origin = self.origin || 'http://' + location.host

      if self.version <= 75
          hash.merge!('WebSocket-Protocol' => self.subprotocol) if self.subprotocol
          hash.merge!('WebSocket-Origin'   => origin)
          hash.merge!('WebSocket-Location' => location.to_s)
      else
          hash.merge!('Sec-WebSocket-Protocol' => self.subprotocol) if self.subprotocol
          hash.merge!('Sec-WebSocket-Origin'   => origin)
          hash.merge!('Sec-WebSocket-Location' => location.to_s)
      end

      unless self.cookies.empty?
        hash.merge!('Set-Cookie' => self.cookies.collect(&:to_s).join(','))
      end

      body = self.checksum if self.version > 75

      hash.merge!('Content-Length' => body.length.to_s)

      return [ status, hash, [ body ]]
    end

    # Build cookies from hash
    # @see LibWebSocket::Cookie
    def cookie=(hash)
      self.cookies.push self.build_cookie(hash)
    end

    # Draft 76 number 1 reader
    def number1
      self.number('number1','key1')
    end
    # Draft 76 number 1 writter
    def number1=(val)
      self.number('number1','key1',val)
    end
    # Draft 76 number 2 reader
    def number2
      self.number('number2','key2')
    end
    # Draft 76 number 2 writter
    def number2=(val)
      self.number('number2','key2',val)
    end

    protected

    def parse_first_line(line)
      unless line =~ /\AHTTP\/1.1 101 .+/
        self.error = 'Wrong response line'
        return
      end

      return self
    end

    def parse_body
      if self.field('Sec-WebSocket-Origin')
        return true if @buffer.length < 16

        self.version = 76

        checksum = @buffer.slice!(0..15)
        self.checksum = checksum
      else
        self.version = 75
      end

      return self if self.finalize

      self.error = 'Not a valid response'
      return
    end

    def finalize
      location = self.field('Sec-WebSocket-Location') || self.field('WebSocket-Location')
      return unless location
      self.location = location

      url = self.build_url
      return unless url.parse(self.location)

      self.secure = url.secure
      self.host = url.host
      self.resource_name = url.resource_name

      self.origin = self.field('Sec-WebSocket-Origin') || self.field('WebSocket-Origin')

      self.subprotocol = self.field('Sec-WebSocket-Protocol') || self.field('WebSocket-Protocol')

      return true
    end

    def build_url(hash = {})
      URL.new(hash)
    end

    def build_cookie(hash = {})
      Cookie::Response.new(hash)
    end

  end
end
