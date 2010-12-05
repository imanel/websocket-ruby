require 'test_helper'

class TestRequest76 < Test::Unit::TestCase

  def test_parse
    req = LibWebSocket::Request.new
    assert !req.done?
    assert req.parse('')
    assert req.parse("GET /demo HTTP/1.1\x0d\x0a")
    assert_equal 'fields', req.state

    assert req.parse("Upgrade: WebSocket\x0d\x0a")
    assert_equal 'fields', req.state
    assert req.parse("Connection: Upgrade\x0d\x0a")
    assert_equal 'fields', req.state
    assert req.parse("Host: example.com\x0d\x0a")
    assert_equal 'fields', req.state
    assert req.parse("Origin: http://example.com\x0d\x0a")
    assert_equal 'fields', req.state
    assert req.parse(
               "Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8\x0d\x0a")
    assert req.parse(
               "Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0\x0d\x0a")
    assert_equal 'fields', req.state
    assert req.parse("\x0d\x0aTm[K T2u")
    assert_equal 'done', req.state
    assert_equal 155712099, req.number1
    assert_equal 173347027, req.number2
    assert_equal 'Tm[K T2u', req.challenge

    assert_equal 76, req.version
    assert_equal '/demo', req.resource_name
    assert_equal 'example.com', req.host
    assert_equal 'http://example.com', req.origin
    assert_equal 'fQJ,fN/4F4!~K~MH', req.checksum
    assert_equal 76, req.version
    assert_equal '/demo', req.resource_name
    assert_equal 'example.com', req.host
    assert_equal 'http://example.com', req.origin
    assert_equal 'fQJ,fN/4F4!~K~MH', req.checksum

    req = LibWebSocket::Request.new
    assert req.parse("GET /demo HTTP/1.1\x0d\x0a")
    assert req.parse("Upgrade: WebSocket\x0d\x0a")
    assert req.parse("Connection: Upgrade\x0d\x0a")
    assert req.parse("Host: example.com\x0d\x0a")
    assert req.parse("Origin: http://example.com\x0d\x0a")
    assert req.parse("Sec-WebSocket-Protocol: sample\x0d\x0a")
    assert req.parse(
               "Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8\x0d\x0a")
    assert req.parse(
               "Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0\x0d\x0a")
    assert req.parse("\x0d\x0aTm[K T2u")
    assert req.done?
    assert_equal 'sample', req.subprotocol
  end

  def test_checksum
    req = LibWebSocket::Request.new(
        :host          => 'example.com',
        :resource_name => '/demo',
        :key1          => '18x 6]8vM;54 *(5:  {   U1]8  z [  8',
        :key2          => '1_ tx7X d  <  nw  334J702) 7]o}` 0',
        :challenge     => 'Tm[K T2u'
    )
    assert_equal req.to_s, "GET /demo HTTP/1.1\x0d\x0a" +
        "Upgrade: WebSocket\x0d\x0a" +
        "Connection: Upgrade\x0d\x0a" +
        "Host: example.com\x0d\x0a" +
        "Origin: http://example.com\x0d\x0a" +
        "Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8\x0d\x0a" +
        "Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0\x0d\x0a" +
        "Content-Length: 8\x0d\x0a" +
        "\x0d\x0a" +
        "Tm[K T2u"
    assert_equal "fQJ,fN/4F4!~K~MH", req.checksum

    req = LibWebSocket::Request.new(
        :host          => 'example.com',
        :resource_name => '/demo',
        :subprotocol   => 'sample',
        :key1          => '18x 6]8vM;54 *(5:  {   U1]8  z [  8',
        :key2          => '1_ tx7X d  <  nw  334J702) 7]o}` 0',
        :challenge     => 'Tm[K T2u'
    )
    assert_equal req.to_s, "GET /demo HTTP/1.1\x0d\x0a" +
        "Upgrade: WebSocket\x0d\x0a" +
        "Connection: Upgrade\x0d\x0a" +
        "Host: example.com\x0d\x0a" +
        "Origin: http://example.com\x0d\x0a" +
        "Sec-WebSocket-Protocol: sample\x0d\x0a" +
        "Sec-WebSocket-Key1: 18x 6]8vM;54 *(5:  {   U1]8  z [  8\x0d\x0a" +
        "Sec-WebSocket-Key2: 1_ tx7X d  <  nw  334J702) 7]o}` 0\x0d\x0a" +
        "Content-Length: 8\x0d\x0a" +
        "\x0d\x0a" +
        "Tm[K T2u";
    assert_equal "fQJ,fN/4F4!~K~MH", req.checksum

    req = LibWebSocket::Request.new(
        :host          => 'example.com',
        :resource_name => '/demo',
        :key1          => '55 997',
        :key2          => '3  3  64  98',
        :challenge     => "\x00\x09\x68\x32\x00\x78\xc7\x10"
    )
    assert_equal req.checksum, "\xc4\x15\xc2\xc8\x29\x5c\x94\x8a\x95\xb9\x4d\xec\x5b\x1d\x33\xce"
  end

  def test_to_s
    req = LibWebSocket::Request.new(
        :host          => 'example.com',
        :resource_name => '/demo'
    )
    req.to_s
    assert req.number1
    assert req.key1
    assert req.number2
    assert req.key2
    assert_equal 8, req.challenge.length
    assert_equal 16, req.checksum.length
  end
end
