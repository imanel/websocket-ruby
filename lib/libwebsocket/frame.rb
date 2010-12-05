module LibWebSocket
  # Construct or parse a WebSocket frame.
  #
  # SYNOPSIS
  #
  #   # Create frame
  #   frame = LibWebSocket::Frame.new('123')
  #   frame.to_s # \x00123\xff
  #
  #   # Parse frames
  #   frame = LibWebSocket::Frame.new
  #   frame.append("123\x00foo\xff56\x00bar\xff789")
  #   frame.next # =>  foo
  #   frame.next # =>  bar
  class Frame

    def initialize(buffer = nil)
      @buffer = buffer || ''
    end

    # Create new frame without modification of current
    def new(buffer = nil)
      self.class.new(buffer)
    end

    # Append a frame chunk.
    # @example
    #   frame.append("\x00foo")
    #   frame.append("bar\xff")
    def append(string = nil)
      return unless string.is_a?(String)

      @buffer += string

      return self
    end

    # Return the next frame.
    # @example
    #   frame.append("\x00foo")
    #   frame.append("\xff\x00bar\xff")
    #
    #   frame.next; # =>  foo
    #   frame.next; # =>  bar
    def next
      return unless @buffer.slice!(/^[^\x00]*\x00(.*?)\xff/m)

      string = $1
      string.force_encoding('UTF-8') if string.respond_to?(:force_encoding)

      return string
    end

    # Construct a WebSocket frame.
    # @example
    #   frame = LibWebSocket::Frame.new('foo')
    #   frame.to_s # => \x00foo\xff
    def to_s
      ary = ["\x00", @buffer.dup, "\xff"]

      ary.collect{ |s| s.force_encoding('UTF-8') if s.respond_to?(:force_encoding) }

      return ary.join
    end

  end
end
