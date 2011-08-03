require 'test_helper'

class TestServerOpeningHandshake < Test::Unit::TestCase

  def test_to_s
    h = LibWebSocket::OpeningHandshake::Client.new
    h.url = 'ws://example.com/demo?param=true&another=hello'

    # Mocking
    h.req.key1 = "18x 6]8vM;54 *(5:  {   U1]8  z [  8"
    h.req.key2 = "1_ tx7X d  <  nw  334J702) 7]o}` 0"
    h.req.challenge = "Tm[K T2u"

    assert_equal h.to_s, "GET /demo?param=true&another=hello HTTP/1.1\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "Host: example.com\x0d\x0a" +
      "Origin: http://example.com\x0d\x0a" +
      "Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8\x0d\x0a" +
      "Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0\x0d\x0a" +
      "Content-Length: 8\x0d\x0a" +
      "\x0d\x0aTm[K T2u"

    h = LibWebSocket::OpeningHandshake::Client.new(:url => 'ws://example.com')

    # Mocking
    h.req.key1 = "18x 6]8vM;54 *(5:  {   U1]8  z [  8"
    h.req.key2 = "1_ tx7X d  <  nw  334J702) 7]o}` 0"
    h.req.challenge = "Tm[K T2u"

    assert_equal h.to_s, "GET / HTTP/1.1\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "Host: example.com\x0d\x0a" +
      "Origin: http://example.com\x0d\x0a" +
      "Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8\x0d\x0a" +
      "Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0\x0d\x0a" +
      "Content-Length: 8\x0d\x0a" +
      "\x0d\x0aTm[K T2u"

    assert !h.done?
    assert h.parse('')

    assert h.parse("HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
          "Upgrade: WebSocket\x0d\x0a" +
          "Connection: Upgrade\x0d\x0a" +
          "Sec-WebSocket-Origin: http://example.com\x0d\x0a" +
          "Sec-WebSocket-Location: ws://example.com/demo\x0d\x0a" +
          "\x0d\x0a" +
          "fQJ,fN/4F4!~K~MH")
    assert !h.error
    assert h.done?

    message = "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a"
    h = LibWebSocket::OpeningHandshake::Client.new(:url => 'ws://example.com')
    assert h.parse(message)
    assert !h.error

    h = LibWebSocket::OpeningHandshake::Client.new
    assert !h.parse("HTTP/1.0 foo bar\x0d\x0a")
    assert_equal 'Wrong response line', h.error
  end

end
