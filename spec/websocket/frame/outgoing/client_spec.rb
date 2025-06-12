# frozen_string_literal: true

require 'spec_helper'

# Dummy handler for Outgoing client frame
class DummyHandlerForOutgoingClient
  def masking?
    # This method in the handler is for `outgoing_masking?` in the frame class.
    # For the `incoming_masking?` test, this can be true or false.
    true
  end
end

RSpec.describe WebSocket::Frame::Outgoing::Client do
  # The Outgoing::Client class, like its parent Outgoing,
  # expects a handler in its initialize method.
  let(:dummy_handler) { DummyHandlerForOutgoingClient.new }
  let(:frame) { WebSocket::Frame::Outgoing::Client.new(handler: dummy_handler) }

  describe '#incoming_masking?' do
    it 'returns false' do
      expect(frame.incoming_masking?).to be false
    end
  end
end
