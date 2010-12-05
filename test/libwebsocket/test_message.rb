require 'test_helper'

class TestMessage < Test::Unit::TestCase

  def test_parse
    m = LibWebSocket::Message.new
    assert m.parse("HTTP/1.1 101 WebSocket Protocol Handshake\x0d\x0a")
    assert m.parse("Upgrade: WebSocket\x0d\x0a")
    assert m.parse("Connection: Upgrade\x0d\x0a")
    assert m.parse("Sec-WebSocket-Origin: file://\x0d\x0a")
    assert m.parse("Sec-WebSocket-Location: ws://example.com/demo\x0d\x0a")
    assert m.parse("\x0d\x0a0st\x0d\x0al&q-2ZU^weu")
    assert m.done?
  end

end
