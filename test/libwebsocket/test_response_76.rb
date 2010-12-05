require 'test_helper'

class TestResponse76 < Test::Unit::TestCase

  def test_parse
    res = LibWebSocket::Response.new
    assert res.parse("HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a")
    assert res.parse("Upgrade: WebSocket\x0d\x0a")
    assert res.parse("Connection: Upgrade\x0d\x0a")
    assert res.parse("Sec-WebSocket-Origin: file://\x0d\x0a")
    assert res.parse("Sec-WebSocket-Location: ws://example.com/demo\x0d\x0a")
    assert res.parse("\x0d\x0a")
    assert res.parse("0st3Rl&q-2ZU^weu")
    assert res.done?
    assert_equal '0st3Rl&q-2ZU^weu', res.checksum
    assert !res.secure
    assert_equal 'example.com', res.host
    assert_equal '/demo', res.resource_name
    assert_equal 'file://', res.origin

    res = LibWebSocket::Response.new
    assert res.parse("HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a")
    assert res.parse("Upgrade: WebSocket\x0d\x0a")
    assert res.parse("Connection: Upgrade\x0d\x0a")
    assert res.parse("Sec-WebSocket-Protocol: sample\x0d\x0a")
    assert res.parse("Sec-WebSocket-Origin: file://\x0d\x0a")
    assert res.parse("Sec-WebSocket-Location: ws://example.com/demo\x0d\x0a")
    assert res.parse("\x0d\x0a")
    assert res.parse("0st3Rl&q-2ZU^weu")
    assert res.done?
    assert_equal 'sample', res.subprotocol

    res = LibWebSocket::Response.new
    message = "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a"
    assert res.parse(message)
    message = "Sec-WebSocket-Origin: file://\x0d\x0a" +
      "Sec-WebSocket-Location: ws://example.com/demo\x0d\x0a" +
      "\x0d\x0a" +
      "0st3Rl&q-2ZU^weu\x00foo\xff"
    assert res.parse(message)
    assert res.done?
  end

  def test_to_s
    res = LibWebSocket::Response.new(
        :host          => 'example.com',
        :resource_name => '/demo',
        :origin        => 'file://',
        :number1       => 777_007_543,
        :number2       => 114_997_259,
        :challenge     => "\x47\x30\x22\x2D\x5A\x3F\x47\x58"
    )
    assert_equal res.to_s, "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "Sec-WebSocket-Origin: file://\x0d\x0a" +
      "Sec-WebSocket-Location: ws://example.com/demo\x0d\x0a" +
      "\x0d\x0a" +
      "0st3Rl&q-2ZU^weu"

    res = LibWebSocket::Response.new(
        :host          => 'example.com',
        :resource_name => '/demo',
        :origin        => 'file://',
        :subprotocol   => 'sample',
        :number1       => 777_007_543,
        :number2       => 114_997_259,
        :challenge     => "\x47\x30\x22\x2D\x5A\x3F\x47\x58"
    );
    assert_equal res.to_s, "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "Sec-WebSocket-Protocol: sample\x0d\x0a" +
      "Sec-WebSocket-Origin: file://\x0d\x0a" +
      "Sec-WebSocket-Location: ws://example.com/demo\x0d\x0a" +
      "\x0d\x0a" +
      "0st3Rl&q-2ZU^weu"

    res = LibWebSocket::Response.new(
        :secure        => true,
        :host          => 'example.com',
        :resource_name => '/demo',
        :origin        => 'file://',
        :number1       => 777_007_543,
        :number2       => 114_997_259,
        :challenge     => "\x47\x30\x22\x2D\x5A\x3F\x47\x58"
    )
    assert_equal res.to_s, "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "Sec-WebSocket-Origin: file://\x0d\x0a" +
      "Sec-WebSocket-Location: wss://example.com/demo\x0d\x0a" +
      "\x0d\x0a" +
      "0st3Rl&q-2ZU^weu"

    res = LibWebSocket::Response.new(
        :host          => 'example.com',
        :resource_name => '/demo',
        :origin        => 'file://',
        :key1          => "18x 6]8vM;54 *(5:  {   U1]8  z [  8",
        :key2          => "1_ tx7X d  <  nw  334J702) 7]o}` 0",
        :challenge     => "Tm[K T2u"
    )
    assert_equal res.to_s, "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "Sec-WebSocket-Origin: file://\x0d\x0a" +
      "Sec-WebSocket-Location: ws://example.com/demo\x0d\x0a" +
      "\x0d\x0a" +
      "fQJ,fN/4F4!~K~MH"
  end

end