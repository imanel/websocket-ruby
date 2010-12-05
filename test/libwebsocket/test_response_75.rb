require 'test_helper'

class TestResponse75 < Test::Unit::TestCase

  def test_to_s
    res = LibWebSocket::Response.new
    res.version = 75
    res.host = 'example.com'
    assert_equal res.to_s, "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "WebSocket-Origin: http://example.com\x0d\x0a" +
      "WebSocket-Location: ws://example.com/\x0d\x0a" +
      "\x0d\x0a"

    res = LibWebSocket::Response.new
    res.version = 75
    res.host = 'example.com'
    res.subprotocol = 'sample'
    assert_equal res.to_s, "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "WebSocket-Protocol: sample\x0d\x0a" +
      "WebSocket-Origin: http://example.com\x0d\x0a" +
      "WebSocket-Location: ws://example.com/\x0d\x0a" +
      "\x0d\x0a";

    res = LibWebSocket::Response.new
    res.version = 75
    res.host = 'example.com'
    res.secure = true
    assert_equal res.to_s, "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "WebSocket-Origin: http://example.com\x0d\x0a" +
      "WebSocket-Location: wss://example.com/\x0d\x0a" +
      "\x0d\x0a";

    res = LibWebSocket::Response.new
    res.version = 75
    res.host = 'example.com'
    res.resource_name = '/demo'
    res.origin = 'file://'
    res.cookie = {:name => 'foo', :value => 'bar', :path => '/'}

    assert_equal res.to_s, "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "WebSocket-Origin: file://\x0d\x0a" +
      "WebSocket-Location: ws://example.com/demo\x0d\x0a" +
      "Set-Cookie: foo=bar; Path=/; Version=1\x0d\x0a" +
      "\x0d\x0a";
  end

  def test_parse
    res = LibWebSocket::Response.new
    res.parse("HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a")
    res.parse("Upgrade: WebSocket\x0d\x0a")
    res.parse("Connection: Upgrade\x0d\x0a")
    res.parse("WebSocket-Protocol: sample\x0d\x0a")
    res.parse("WebSocket-Origin: file://\x0d\x0a")
    res.parse("WebSocket-Location: ws://example.com/demo\x0d\x0a")
    res.parse("\x0d\x0a\x00foo\xff")
    assert res.done?
    assert_equal 75, res.version
    assert_equal 'sample', res.subprotocol

    message = "HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a" +
      "Upgrade: WebSocket\x0d\x0a" +
      "Connection: Upgrade\x0d\x0a" +
      "WebSocket-Origin: file://\x0d\x0a" +
      "WebSocket-Location: ws://example.com/demo\x0d\x0a" +
      "\x0d\x0a\x00foo\xff"
    res = LibWebSocket::Response.new
    assert res.parse(message)
    assert res.done?
    assert_equal 75, res.version
  end

end