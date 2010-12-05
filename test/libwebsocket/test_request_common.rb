require 'test_helper'

class TestRequestCommon < Test::Unit::TestCase

  def test_parse
    req = LibWebSocket::Request.new
    assert !req.done?
    assert_nil req.parse("foo\x0d\x0a")
    assert_equal 'error', req.state
    assert_equal 'Wrong request line', req.error

    req = LibWebSocket::Request.new
    assert req.parse("GET /demo HTTP/1.1\x0d\x0a")
    assert req.parse("Upgrade: WebSocket\x0d\x0a")
    assert req.parse("Connection: Upgrade\x0d\x0a")
    assert req.parse("Origin: http://example.com\x0d\x0a")
    assert_nil req.parse("\x0d\x0a")
    assert_equal 'error', req.state

    req = LibWebSocket::Request.new
    assert_nil req.parse('x' * (1024 * 10))
    assert_equal 'error', req.state
    assert_equal 'Message is too long', req.error
  end

end
