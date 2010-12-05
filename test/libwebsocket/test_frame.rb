require 'test_helper'

class TestFrame < Test::Unit::TestCase

  def test_append
    f = LibWebSocket::Frame.new

    f.append
    assert_nil f.next
    f.append('')
    assert_nil f.next

    f.append('qwe')
    assert_nil f.next
    f.append("\x00foo\xff")
    assert_equal 'foo', f.next
    assert_nil f.next

    f.append("\x00")
    assert_nil f.next
    f.append("\xff")
    assert_equal '', f.next

    f.append("\x00")
    assert_nil f.next
    f.append("foo")
    f.append("\xff")
    assert_equal 'foo', f.next

    f.append("\x00foo\xff\x00bar\n\xff")
    assert_equal 'foo', f.next
    assert_equal "bar\n", f.next
    assert_nil f.next

    f.append("123\x00foo\xff56\x00bar\xff789")
    assert_equal 'foo', f.next
    assert_equal 'bar', f.next
    assert_nil f.next

    # We append bytes, but read characters
    msg = "\342\230\272"
    f.append("\x00" + msg + "\xff")
    msg.force_encoding('UTF-8') if msg.respond_to?(:force_encoding)
    assert_equal msg, f.next
  end

  def test_new
    f = LibWebSocket::Frame.new
    msg = "\x00\xff"
    msg.force_encoding('UTF-8') if msg.respond_to?(:force_encoding)
    assert_equal msg, f.to_s

    f = LibWebSocket::Frame.new('123')
    msg = "\x00123\xff"
    msg.force_encoding('UTF-8') if msg.respond_to?(:force_encoding)
    assert_equal msg, f.to_s

    # We pass characters, but send bytes
    f = LibWebSocket::Frame.new("\342\230\272")
    msg = "\x00\342\230\272\xff"
    msg.force_encoding('UTF-8') if msg.respond_to?(:force_encoding)
    assert_equal msg, f.to_s
  end

end