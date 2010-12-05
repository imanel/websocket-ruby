module LibWebSocket
  #A base class for LibWebSocket::Cookie::Request and LibWebSocket::Cookie::Response.
  class Cookie

    autoload :Request,  "#{File.dirname(__FILE__)}/cookie/request"
    autoload :Response, "#{File.dirname(__FILE__)}/cookie/response"

    attr_accessor :pairs

    TOKEN         = /[^;,\s"]+/ # Cookie token
    NAME          = /[^;,\s"=]+/ # Cookie name
    QUOTED_STRING = /"(?:\\"|[^"])+"/ # Cookie quoted value
    VALUE         = /(?:#{TOKEN}|#{QUOTED_STRING})/ # Cookie unquoted value

    def initialize(hash = {})
      hash.each do |k,v|
        instance_variable_set("@#{k}",v)
      end
    end

    # Parse cookie string to array
    def parse(string)
      self.pairs = []

      return if string.nil? || string == ''

      while string.slice!(/\s*(#{NAME})\s*(?:=\s*(#{VALUE}))?;?/)
        attr, value = $1, $2
        if !value.nil?
          value.gsub!(/^"/, '')
          value.gsub!(/"$/, '')
          value.gsub!(/\\"/, '"')
        end
        self.pairs.push([attr, value])
      end

      return self
    end

    # Convert cookie array to string
    def to_s
      pairs = []

      self.pairs.each do |pair|
        string = ''
        string += pair[0]

        unless pair[1].nil?
          string += '='
          string += (!pair[1].match(/^#{VALUE}$/) ? "\"#{pair[1]}\"" : pair[1])
        end

        pairs.push(string)
      end

      return pairs.join("; ")
    end

  end
end
