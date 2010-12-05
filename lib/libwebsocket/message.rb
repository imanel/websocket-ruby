require 'digest/md5'

module LibWebSocket
  # A base class for LibWebSocket::Request and LibWebSocket::Response.
  class Message
    include Stateful

    attr_accessor :fields, :error, :subprotocol, :host, :origin, :version, :number1, :number2, :challenge, :checksum

    # A new instance of Message.
    # Instance variables will be set from hash.
    # @example
    #   msg = LibMessage.new( :host => 'example.org' )
    #   msg.host # => 'example.org'
    def initialize(hash = {})
      hash.each do |k,v|
        instance_variable_set("@#{k}",v)
      end

      @version ||= 76
      @buffer = ''
      @fields ||= {}
      @max_message_size ||= 2048
      @cookies ||= []
      @state = 'first_line'
    end

    # Alias for fields.
    # Use this instead of fields directly to preserve normalization(lowercase etc.)
    def field(f, val = nil)
      name = f.downcase

      return self.fields[name] unless val

      self.fields[name] = val

      return self
    end

    # Set state to 'error' and write error message
    def error=(val)
      @error = val
      self.state = 'error'
    end

    # Calculate Draft 76 checksum
    def checksum
      return @checksum if @checksum

      raise 'number1 is required'   unless self.number1
      raise 'number2 is required'   unless self.number2
      raise 'challenge is required' unless self.challenge

      checksum = ''
      checksum += [self.number1].pack('N')
      checksum += [self.number2].pack('N')
      checksum += self.challenge
      checksum = Digest::MD5.digest(checksum)

      return @checksum ||= checksum
    end

    # Parse string
    # @see LibWebSocket::Request#parse
    # @see LibWebSocket::Response#parse
    def parse(string)
      return unless string.is_a?(String)

      return if self.error

      return unless self.append(string)

      while(!self.state?('body') && line = self.get_line)
        if self.state?('first_line')
          return unless self.parse_first_line(line)

          self.state = 'fields'
        elsif line != ''
          return unless self.parse_field(line)
        else
          self.state = 'body'
          break
        end
      end

      return true unless self.state?('body')

      rv = self.parse_body
      return unless rv

      # Need more data
      return rv unless rv != true

      return self.done
    end

    protected

    def number(name, key, value = nil)
      if value
        return self.instance_variable_set("@#{name}", value)
      end

      return self.instance_variable_get("@#{name}") if self.instance_variable_get("@#{name}")

      return self.instance_variable_set("@#{name}", self.extract_number(self.send(key)))
    end

    def extract_number(key)
      number = ''
      while key.slice!(/(\d)/)
        number += $1
      end
      number = number.to_i

      spaces = 0
      while key.slice!(/ /)
        spaces += 1
      end

      return if spaces == 0

      return (number / spaces).to_i
    end

    def append(data)
      return if self.error

      @buffer += data

      if @buffer.length > @max_message_size
        self.error = 'Message is too long'
        return
      end

      return self
    end

    def get_line
      if @buffer.slice!(/\A(.*?)\x0d?\x0a/)
        return $1
      end
      return
    end

    def parse_first_line(line)
      self
    end

    def parse_field(line)
      name, value = line.split(': ', 2)
      unless name && value
        self.error = 'Invalid field'
        return
      end

      self.field(name, value)

      return self
    end

    def parse_body
      self
    end

  end
end
