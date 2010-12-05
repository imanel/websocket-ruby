require 'test_helper'

class TestCookie < Test::Unit::TestCase

  def test_parse
    cookie = LibWebSocket::Cookie.new
    assert_nil cookie.parse('')
    assert cookie.parse('foo=bar; baz = zab; hello= "the;re"; here')
    assert_equal [['foo', 'bar'], ['baz', 'zab'], ['hello', 'the;re'], ['here', nil]], cookie.pairs
    assert_equal 'foo=bar; baz=zab; hello="the;re"; here', cookie.to_s

    cookie = LibWebSocket::Cookie.new
    cookie.parse('$Foo="bar"')
    assert_equal [['$Foo', 'bar']], cookie.pairs

    cookie = LibWebSocket::Cookie.new
    cookie.parse('foo=bar=123=xyz')
    assert_equal [['foo', 'bar=123=xyz']], cookie.pairs
  end

end
