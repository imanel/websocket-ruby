# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Handshake handler internal helpers' do
  describe WebSocket::Handshake::Handler::Client76 do
    it 'reserves one leftover line for the hixie-76 challenge response' do
      handler = described_class.new(nil)
      expect(handler.send(:reserved_leftover_lines)).to be(1)
    end
  end

  describe WebSocket::Handshake::Handler::Server76 do
    it 'reserves one leftover line for the hixie-76 challenge response' do
      handler = described_class.new(nil)
      expect(handler.send(:reserved_leftover_lines)).to be(1)
    end
  end
end
