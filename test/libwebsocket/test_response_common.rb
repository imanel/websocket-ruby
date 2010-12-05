require 'test_helper'

class TestResponseCommon < Test::Unit::TestCase

  def test_parse
    res = LibWebSocket::Response.new
    res.parse("foo\x0d\x0a")
    assert_equal 'error', res.state
    assert_equal 'Wrong response line', res.error

    res = LibWebSocket::Response.new
    assert_nil res.parse('x' * (1024 * 10))
    assert_equal 'error', res.state
    assert_equal 'Message is too long', res.error
  end

end
