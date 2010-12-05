require 'test_helper'

class TestServerOpeningHandshake < Test::Unit::TestCase

  def test_parse
    h = LibWebSocket::OpeningHandshake::Server.new
    assert !h.done?
    assert h.parse('')

    assert h.parse("GET /demo HTTP/1.1\x0d\x0a")
    assert h.parse("Upgrade: WebSocket\x0d\x0a")
    assert h.parse("Connection: Upgrade\x0d\x0a")
    assert h.parse("Host: example.com\x0d\x0a")
    assert h.parse("Origin: http://example.com\x0d\x0a")
    assert h.parse("Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8\x0d\x0a")
    assert h.parse("Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0\x0d\x0a")
    assert h.parse("\x0d\x0aTm[K T2u")
    assert !h.error
    assert h.done?

    assert_equal h.to_s, "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "Sec-WebSocket-Origin: http://example.com\x0d\x0a" +
      "Sec-WebSocket-Location: ws://example.com/demo\x0d\x0a" +
      "\x0d\x0a" +
      "fQJ,fN/4F4!~K~MH";

    message = "GET /demo HTTP/1.1\x0d\x0a"
    h = LibWebSocket::OpeningHandshake::Server.new
    assert h.parse(message)
    assert_nil h.error

    h = LibWebSocket::OpeningHandshake::Server.new
    assert_nil h.parse("GET /demo\x0d\x0a")
    assert_equal 'Wrong request line', h.error
  end

end
