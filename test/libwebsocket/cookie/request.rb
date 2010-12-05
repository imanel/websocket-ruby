require 'test_helper'

class TestCookieRequest < Test::Unit::TestCase

  def test_parse
    cookie  = LibWebSocket::Cookie::Request.new
    cookies = cookie.parse('$Version=1; foo=bar; $Path=/; $Domain=.example.com')
    assert_equal 'foo', cookies[0].name
    assert_equal 'bar', cookies[0].value
    assert_equal 1, cookies[0].version
    assert_equal '/', cookies[0].path
    assert_equal '.example.com', cookies[0].domain

    cookie  = LibWebSocket::Cookie::Request.new
    cookies = cookie.parse('$Version=1; foo=bar')
    assert_equal 'foo', cookies[0].name
    assert_equal 'bar', cookies[0].value
    assert_equal 1, cookies[0].version
    assert_equal nil, cookies[0].path
    assert_equal nil, cookies[0].domain

    cookie  = LibWebSocket::Cookie::Request.new
    cookies = cookie.parse('$Version=1; foo="hello\"there"')
    assert_equal 'foo', cookies[0].name
    assert_equal 'hello"there', cookies[0].value

    cookie  = LibWebSocket::Cookie::Request.new
    cookies = cookie.parse('$Version=1; foo="bar"; $Path=/; bar=baz; $Domain=.example.com')
    assert_equal 'foo', cookies[0].name
    assert_equal 'bar', cookies[0].value
    assert_equal '/', cookies[0].path
    assert_equal 'bar', cookies[1].name
    assert_equal 'baz', cookies[1].value
    assert_equal '.example.com', cookies[1].domain
  end

end
