require 'addressable/uri'

module LibWebSocket
  # Construct or parse a WebSocket URL.
  class URL

    attr_accessor :secure, :host, :port, :resource_name

    def initialize(hash = {})
      hash.each do |k,v|
        instance_variable_set("@#{k}",v)
      end

      @secure ||= false
    end

    # Parse a WebSocket URL.
    # @example Parse
    #   url = LibWebSocket::URL.new
    #   url.parse('wss://example.com:3000')
    #   url.host   # => example.com
    #   url.port   # => 3000
    #   url.secure # => true
    def parse(string)
      return nil unless string.is_a?(String)

      uri = Addressable::URI.parse(string)

      scheme = uri.scheme
      return nil unless scheme

      self.secure = true if scheme.match(/ss\Z/m)

      host = uri.host
      host = '/' unless host && host != ''
      self.host = host
      self.port = uri.port.to_s if uri.port

      request_uri = uri.path
      request_uri = '/' unless request_uri && request_uri != ''
      request_uri += "?" + uri.query if uri.query
      self.resource_name = request_uri

      return self
    end

    # Construct a WebSocket URL.
    # @example Construct
    #   url = LibWebSocket::URL.new
    #   url.host = 'example.com'
    #   url.port = '3000'
    #   url.secure = true
    #   url.to_s # => 'wss://example.com:3000'
    def to_s
      string = ''

      string += 'ws'
      string += 's' if self.secure
      string += '://'
      string += self.host
      string += ':' + self.port.to_s if self.port
      string += self.resource_name || '/'

      return string
    end

  end
end
