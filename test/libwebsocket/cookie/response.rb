require 'test_helper'

class TestCookieResponse < Test::Unit::TestCase

  def test_to_s
    cookie = LibWebSocket::Cookie::Response.new(:name => 'foo', :value => 'bar')
    assert_equal 'foo=bar; Version=1', cookie.to_s

    cookie = LibWebSocket::Cookie::Response.new(
        :name    => 'foo',
        :value   => 'bar',
        :discard => 1,
        :max_age => 0
    )
    assert_equal 'foo=bar; Discard; Max-Age=0; Version=1', cookie.to_s

    cookie = LibWebSocket::Cookie::Response.new(
        :name     => 'foo',
        :value    => 'bar',
        :portlist => 80
    )
    assert_equal 'foo=bar; Port="80"; Version=1', cookie.to_s

    cookie = LibWebSocket::Cookie::Response.new(
        :name     => 'foo',
        :value    => 'bar',
        :portlist => [80, 443]
    )
    assert_equal 'foo=bar; Port="80 443"; Version=1', cookie.to_s
  end

end
