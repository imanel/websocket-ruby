require 'test_helper'

class TestURL < Test::Unit::TestCase

  def test_parse
    url = LibWebSocket::URL.new
    assert url.parse('ws://example.com/')
    assert !url.secure
    assert_equal 'example.com', url.host
    assert_equal '/', url.resource_name

    url = LibWebSocket::URL.new
    assert url.parse('ws://example.com/demo')
    assert !url.secure
    assert_equal 'example.com', url.host
    assert_equal '/demo', url.resource_name

    url = LibWebSocket::URL.new
    assert url.parse('ws://example.com:3000')
    assert !url.secure
    assert_equal 'example.com', url.host
    assert_equal '3000', url.port
    assert_equal '/', url.resource_name

    url = LibWebSocket::URL.new
    assert url.parse('ws://example.com/demo?foo=bar')
    assert !url.secure
    assert_equal 'example.com', url.host
    assert_equal '/demo?foo=bar', url.resource_name
  end

  def test_to_s
    url = LibWebSocket::URL.new(:host => 'foo.com', :secure => true);
    assert_equal 'wss://foo.com/', url.to_s

    url = LibWebSocket::URL.new(
        :host          => 'foo.com',
        :resource_name => '/demo'
    )
    assert_equal 'ws://foo.com/demo', url.to_s

    url = LibWebSocket::URL.new(
        :host => 'foo.com',
        :port => 3000
    )
    assert_equal 'ws://foo.com:3000/', url.to_s
  end

end
