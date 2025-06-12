# frozen_string_literal: true

require 'spec_helper'

# Dummy class needed to instantiate the handler
class DummyFrameForHandlerBase < WebSocket::Frame::Base
  def supported_frames
    # Doesn't matter for these tests, but needs to be implemented
    [:dummy]
  end
end

RSpec.describe WebSocket::Frame::Handler::Base do
  let(:dummy_frame_instance) { DummyFrameForHandlerBase.new }
  let(:handler) { WebSocket::Frame::Handler::Base.new(dummy_frame_instance) }

  describe '#encode_frame' do
    it 'raises NotImplementedError' do
      expect { handler.encode_frame }.to raise_error(NotImplementedError)
    end
  end

  describe '#decode_frame' do
    it 'raises NotImplementedError' do
      expect { handler.decode_frame }.to raise_error(NotImplementedError)
    end
  end
end
