require 'test_helper'

class TestRequest75 < Test::Unit::TestCase

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
    assert req.parse("\x0d\x0a")
    assert_equal 'done', req.state

    assert_equal 75, req.version
    assert_equal '/demo', req.resource_name
    assert_equal 'example.com', req.host
    assert_equal 'http://example.com', req.origin

    req = LibWebSocket::Request.new
    assert req.parse("GET /demo HTTP/1.1\x0d\x0a")
    assert req.parse("Upgrade: WebSocket\x0d\x0a")
    assert req.parse("Connection: Upgrade\x0d\x0a")
    assert req.parse("Host: example.com:3000\x0d\x0a")
    assert req.parse("Origin: null\x0d\x0a")
    assert req.parse("\x0d\x0a")
    assert_equal 75, req.version
    assert_equal 'done', req.state

    req = LibWebSocket::Request.new
    assert req.parse("GET /demo HTTP/1.1\x0d\x0a")
    assert req.parse("UPGRADE: WebSocket\x0d\x0a")
    assert req.parse("CONNECTION: Upgrade\x0d\x0a")
    assert req.parse("HOST: example.com:3000\x0d\x0a")
    assert req.parse("ORIGIN: null\x0d\x0a")
    assert req.parse("\x0d\x0a")
    assert_equal 75, req.version
    assert_equal 'done', req.state

    req = LibWebSocket::Request.new
    assert req.parse("GET /demo HTTP/1.1\x0d\x0a")
    assert req.parse("Upgrade: WebSocket\x0d\x0a")
    assert req.parse("Connection: Upgrade\x0d\x0a")
    assert req.parse("Host: example.com:3000\x0d\x0a")
    assert req.parse("Origin: null\x0d\x0a")
    assert req.parse("WebSocket-Protocol: sample\x0d\x0a")
    assert req.parse("\x0d\x0a")
    assert_equal 75, req.version
    assert_equal 'done', req.state
    assert_equal 'sample', req.subprotocol

    req     = LibWebSocket::Request.new
    message = "GET /demo HTTP/1.1\x0d\x0a" +
        "Upgrade: WebSocket\x0d\x0a" +
        "Connection: Upgrade\x0d\x0a"
    assert req.parse(message)
    message = "Host: example.com:3000\x0d\x0a" + "Origin: null\x0d\x0a" + "\x0d\x0a"
    assert req.parse(message)
    assert_equal 75, req.version
    assert req.done?

    req = LibWebSocket::Request.new
    assert req.parse("GET /demo HTTP/1.1\x0d\x0a")
    assert req.parse("Upgrade: WebSocket\x0d\x0a")
    assert req.parse("Connection: Upgrade\x0d\x0a")
    assert req.parse("Host: example.com\x0d\x0a")
    assert req.parse("Origin: null\x0d\x0a")
    assert req.parse("cookie: \$Version=1; foo=bar; \$Path=/\x0d\x0a")
    assert req.parse("\x0d\x0a")
    assert req.done?

    assert_equal req.cookies[0].version, '1'
    assert_equal req.cookies[0].name, 'foo'
    assert_equal req.cookies[0].value, 'bar'

    req = LibWebSocket::Request.new
    assert req.parse("GET /demo HTTP/1.1\x0d\x0a")
    assert req.parse("Upgrade: WebSocket\x0d\x0a")
    assert req.parse("Connection: Bar\x0d\x0a")
    assert req.parse("Host: example.com\x0d\x0a")
    assert req.parse("Origin: http://example.com\x0d\x0a")
    assert_nil req.parse("\x0d\x0a")
    assert_equal 'error', req.state
    assert_equal 'Not a valid request', req.error

    req = LibWebSocket::Request.new
    assert req.parse("GET /demo HTTP/1.1\x0d\x0a")
    assert req.parse("Upgrade: WebSocket\x0d\x0a")
    assert req.parse("Connection: Upgrade\x0d\x0a")
    assert req.parse("Host: example.com\x0d\x0a")
    assert req.parse("Origin: http://example.com\x0d\x0a")
    assert_nil req.parse("\x0d\x0afoo")
    assert_equal 'error', req.state
    assert_equal 'Leftovers', req.error
  end

  def test_to_s
    req = LibWebSocket::Request.new(
        :version       => 75,
        :host          => 'example.com',
        :resource_name => '/demo'
    )
    assert_equal req.to_s, "GET /demo HTTP/1.1\x0d\x0a" +
        "Upgrade: WebSocket\x0d\x0a" +
        "Connection: Upgrade\x0d\x0a" +
        "Host: example.com\x0d\x0a" +
        "Origin: http://example.com\x0d\x0a" +
        "\x0d\x0a"

    req = LibWebSocket::Request.new(
        :version       => 75,
        :host          => 'example.com',
        :subprotocol   => 'sample',
        :resource_name => '/demo'
    )
    assert_equal req.to_s, "GET /demo HTTP/1.1\x0d\x0a" +
        "Upgrade: WebSocket\x0d\x0a" +
        "Connection: Upgrade\x0d\x0a" +
        "Host: example.com\x0d\x0a" +
        "Origin: http://example.com\x0d\x0a" +
        "WebSocket-Protocol: sample\x0d\x0a" +
        "\x0d\x0a"

    req = LibWebSocket::Request.new(
        :version       => 75,
        :host          => 'example.com',
        :resource_name => '/demo'
    );
    assert_equal req.to_s, "GET /demo HTTP/1.1\x0d\x0a" +
        "Upgrade: WebSocket\x0d\x0a" +
        "Connection: Upgrade\x0d\x0a" +
        "Host: example.com\x0d\x0a" +
        "Origin: http://example.com\x0d\x0a" +
        "\x0d\x0a"
  end

end
