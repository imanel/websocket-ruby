require "socket"
require File.expand_path(File.dirname(__FILE__) + '/../lib/libwebsocket')

class WebSocket

  def initialize(url, params = {})
    @hs ||= LibWebSocket::OpeningHandshake::Client.new(:url => url, :version => params[:version])
    @frame ||= LibWebSocket::Frame.new

    @socket = TCPSocket.new(@hs.url.host, @hs.url.port || 80)

    @socket.write(@hs.to_s)
    @socket.flush

    loop do
      data = @socket.getc
      next if data.nil?

      result = @hs.parse(data.chr)

      raise @hs.error unless result

      if @hs.done?
        @handshaked = true
        break
      end
    end
  end

  def send(data)
    raise "no handshake!" unless @handshaked

    data = @frame.new(data).to_s
    @socket.write data
    @socket.flush
  end

  def receive
    raise "no handshake!" unless @handshaked

    data = @socket.gets("\xff")
    @frame.append(data)

    messages = []
    while message = @frame.next
      messages << message
    end
    messages
  end

  def socket
    @socket
  end

  def close
    @socket.close
  end

end