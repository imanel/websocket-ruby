module LibWebSocket
  # Construct or parse a WebSocket request.
  class Request < Message

    attr_accessor :cookies, :resource_name

    # Parse a WebSocket request.
    # @param [String] opts parse string
    # @param [Hash] opts parse rack env hash
    # @see Request#parse_rack_env
    # @example Parser
    #   req = LibWebSocket::Request.new
    #   req.parse("GET /demo HTTP/1.1\x0d\x0a")
    #   req.parse("Upgrade: WebSocket\x0d\x0a")
    #   req.parse("Connection: Upgrade\x0d\x0a")
    #   req.parse("Host: example.com\x0d\x0a")
    #   req.parse("Origin: http://example.com\x0d\x0a")
    #   req.parse("Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8\x0d\x0a")
    #   req.parse("Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0\x0d\x0a")
    #   req.parse("\x0d\x0aTm[K T2u")
    def parse(opts)
      case opts
      when String then super
      when Hash then parse_rack_env(opts)
      end
    end

    # Parse a WebSocket request.
    # @param [Hash] env parse rack env hash
    # @example Parser
    #   req = LibWebSocket::Request.new
    #   req.parse(env)
    def parse_rack_env(env)
      method = env['REQUEST_METHOD']
      unless method == 'GET'
        self.error = 'Wrong request method'
        return false
      end

      self.resource_name = env['REQUEST_URI']

      env.keys.select { |v| v =~ /\AHTTP\_/ }.each do |key|
        self.field(key.gsub(/\AHTTP\_/, "").gsub('_','-'), env[key])
      end

      body = env['rack.input']
      # Is compatible with rack.input spec?
      unless body.respond_to?(:rewind) and body.respond_to?(:read)
        self.error = "Invalid rack input"
        return false
      end

      body.rewind
      @buffer = body.read

      rv = self.parse_body
      return unless rv

      # Need more data
      return rv unless rv != true

      return self.done
    end

    # A shortcut for self.field('Upgrade')
    def upgrade
      self.field('Upgrade')
    end
    # A shortcut for self.field('Connection')
    def connection
      self.field('Connection')
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
    # Draft 76 Sec-WebSocket-Key1 reader
    def key1
      self.key('key1')
    end
    # Draft 76 Sec-WebSocket-Key1 writter
    def key1=(val)
      self.key('key1',val)
    end
    # Draft 76 Sec-WebSocket-Key2 reader
    def key2
      self.key('key2')
    end
    # Draft 76 Sec-WebSocket-Key2 writter
    def key2=(val)
      self.key('key2',val)
    end

    # Construct a WebSocket request.
    #     # Constructor
    #     my $req = Protocol::WebSocket::Request.new(
    #         host          => 'example.com',
    #         resource_name => '/demo'
    #     );
    #     $req.to_s # GET /demo HTTP/1.1
    #               # Upgrade: WebSocket
    #               # Connection: Upgrade
    #               # Host: example.com
    #               # Origin: http://example.com
    #               # Sec-WebSocket-Key1: 32 0  3lD& 24+<    i u4  8! -6/4
    #               # Sec-WebSocket-Key2: 2q 4  2  54 09064
    #               #
    #               # x#####
    def to_s
      string = ''

      raise 'resource_name is required' unless self.resource_name
      string += "GET " + self.resource_name + " HTTP/1.1\x0d\x0a"

      string += "Upgrade: WebSocket\x0d\x0a"
      string += "Connection: Upgrade\x0d\x0a"

      raise 'Host is required' unless self.host
      string += "Host: " + self.host + "\x0d\x0a"

      origin = self.origin || 'http://' + self.host
      string += "Origin: " + origin + "\x0d\x0a"

      if self.version > 75
        self.generate_keys

        string += 'Sec-WebSocket-Protocol: ' + self.subprotocol + "\x0d\x0a" if self.subprotocol

        string += 'Sec-WebSocket-Key1: ' + self.key1 + "\x0d\x0a"
        string += 'Sec-WebSocket-Key2: ' + self.key2 + "\x0d\x0a"

        string += 'Content-Length: ' + self.challenge.length.to_s + "\x0d\x0a"
      else
        string += 'WebSocket-Protocol: ' + self.subprotocol + "\x0d\x0a" if self.subprotocol
      end

      # TODO cookies

      string += "\x0d\x0a"

      string += self.challenge if self.version > 75

      return string
    end

    protected

    def parse_first_line(line)
      req, resource_name, http = line.split(' ')

      unless req && resource_name && http
        self.error = 'Wrong request line'
        return
      end

      unless req == 'GET' && http == 'HTTP/1.1'
        self.error = 'Wrong method or http version'
        return
      end

      self.resource_name = resource_name

      return self
    end

    def parse_body
      if self.key1 && self.key2
        return true if @buffer.length < 8

        challenge = @buffer.slice!(0..7)
        self.challenge = challenge
      else
        self.version = 75
      end

      if @buffer.length > 0
        self.error = 'Leftovers'
        return
      end

      return self if self.finalize

      self.error = 'Not a valid request'
      return
    end

    def key(name, value = nil)
      unless value
        if value = self.instance_variable_get("@#{name}")
          self.field("Sec-WebSocket-" + name.capitalize, value)
        end

        return self.field("Sec-WebSocket-" + name.capitalize)
      end

      return self.field("Sec-WebSocket-" + name.capitalize, value)

      return self
    end

    def generate_keys
      unless self.key1
        number, key = self.generate_key
        self.number1 = number
        self.key1 = key
      end

      unless self.key2
        number, key = self.generate_key
        self.number2 = number
        self.key2 = key
      end

      self.challenge ||= self.generate_challenge

      return self
    end

    NOISE_CHARS = ("\x21".."\x2f").to_a + ("\x3a".."\x7e").to_a # From spec

    def generate_key
      spaces = 1 + rand(12)
      max = 4_294_967_295 / spaces
      number = rand(max + 1)
      key = (number * spaces).to_s
      (1 + rand(12)).times do
        char = NOISE_CHARS[rand(NOISE_CHARS.size)]
        pos = rand(key.size + 1)
        key[pos...pos] = char
      end
      spaces.times do
        pos = 1 + rand(key.size - 1)
        key[pos...pos] = " "
      end
      return [number, key]
    end

    def generate_challenge
      challenge = ''
      8.times do
        challenge += rand(256).chr
      end

      return challenge
    end

    def finalize
      return unless self.upgrade    && self.upgrade    == 'WebSocket'
      return unless self.connection && self.connection == 'Upgrade'

      origin = self.field('Origin')
      return unless origin
      self.origin = origin

      host = self.field('Host')
      return unless host
      self.host = host

      subprotocol = self.field('Sec-WebSocket-Protocol') || self.field('WebSocket-Protocol')
      self.subprotocol = subprotocol if subprotocol

      cookie = self.build_cookie
      if cookies = cookie.parse(self.fields['cookie'])
         self.cookies = cookies
      end

      return self
    end

    def build_cookie
      Cookie::Request.new
    end

  end
end
