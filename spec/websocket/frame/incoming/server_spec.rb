# frozen_string_literal: true

require 'spec_helper'

# Dummy handler for Server incoming frame
class DummyHandlerForIncomingServer
  def masking?
    true # Or false, doesn't matter for the specific line being tested
  end
end

RSpec.describe WebSocket::Frame::Incoming::Server do
  # The Incoming::Server class itself doesn't do much in initialize
  # beyond what its parent `Incoming` does.
  # The `Incoming` class expects a handler in its initialize method.
  let(:dummy_handler) { DummyHandlerForIncomingServer.new }
  let(:frame) { WebSocket::Frame::Incoming::Server.new(handler: dummy_handler) }

  describe '#outgoing_masking?' do
    it 'returns false' do
      expect(frame.outgoing_masking?).to be false
    end
  end
end
