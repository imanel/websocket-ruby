module LibWebSocket
  # This is a base class for LibWebSocket::OpeningHandshake::Client and LibWebSocket::OpeningHandshake::Server.
  class OpeningHandshake

    autoload :Client, "#{File.dirname(__FILE__)}/opening_handshake/client"
    autoload :Server, "#{File.dirname(__FILE__)}/opening_handshake/server"

    attr_accessor :secure, :error

    # Convert all hash keys to instance variables.
    def initialize(hash = {})
      hash.each do |k,v|
        instance_variable_set("@#{k}",v)
      end
    end

    # WebSocket request object.
    def req
      @req ||= Request.new
    end

    # WebSocket response object.
    def res
      @res ||= Response.new
    end

  end
end
