# frozen_string_literal: true

require 'spec_helper'

# Dummy Handshake class for testing the Handler::Base
class DummyHandshakeForHandler < WebSocket::Handshake::Base
  # No specific methods needed for this Handler::Base test,
  # as Handler::Base doesn't call much on the handshake object directly for to_s.
end

RSpec.describe WebSocket::Handshake::Handler::Base do
  let(:dummy_handshake_instance) { DummyHandshakeForHandler.new(host: 'example.com') } # host is required by Base Handshake
  let(:handler) { WebSocket::Handshake::Handler::Base.new(dummy_handshake_instance) }

  describe '#to_s' do
    it 'returns the basic structure which covers header_line' do
      # header_line returns ''
      # handshake_keys returns []
      # finishing_line returns ''
      # Expected: "" (from header_line) + "\r\n" + "" (from empty handshake_keys loop) + "" (from result << '') + "\r\n" + "" (from finishing_line)
      # The join is with "\r\n"
      # So: header_line_result + \r\n + key_lines_result + \r\n + '' + \r\n + finishing_line_result
      # If header_line = '', handshake_keys = [], finishing_line = ''
      # Then: "" + "\r\n" + "" + "\r\n" + "" = "\r\n\r\n" (actually, it's just two newlines, then the final join)
      # Let's trace:
      # result = [''] (from header_line)
      # handshake_keys.each -> loop doesn't run
      # result << '' -> result is ['', '']
      # result << '' (from finishing_line) -> result is ['', '', '']
      # result.join("\r\n") -> "\r\n\r\n"
      expect(handler.to_s).to eq("\r\n\r\n")
    end
  end

  describe '#valid?' do
    it 'returns true' do
      expect(handler.valid?).to be true
    end
  end
end
