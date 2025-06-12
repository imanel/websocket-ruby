# frozen_string_literal: true

require 'spec_helper'

# Dummy frame class for testing Handler75
class DummyFrameForHandler75 < WebSocket::Frame::Base
  attr_accessor :type, :data, :version, :code

  def initialize(args = {})
    super(args.merge(version: 75)) # Ensure version is 75 for this handler
    @type = args[:type] if args[:type]
    @data = args[:data] || ''
  end

  # This method is required by the Base class but not directly used by Handler75 spec for this line
  def supported_frames
    [:text, :close]
  end
end

RSpec.describe WebSocket::Frame::Handler::Handler75 do
  describe '#encode_frame' do
    context 'when frame type is unknown' do
      it 'raises WebSocket::Error::Frame::UnknownFrameType' do
        # Use a type not in [:text, :close]
        frame_with_unknown_type = DummyFrameForHandler75.new(type: :ping)
        handler = WebSocket::Frame::Handler::Handler75.new(frame_with_unknown_type)
        expect { handler.encode_frame }.to raise_error(WebSocket::Error::Frame::UnknownFrameType)
      end
    end

    # It might be good to add tests for the valid :text and :close cases
    # to ensure the rest of the method is covered, if not already by other specs.
    # For now, focusing on the specifically identified uncovered line.
    context 'when frame type is :text' do
      it 'encodes text frame correctly' do
        frame = DummyFrameForHandler75.new(type: :text, data: 'Hello')
        handler = WebSocket::Frame::Handler::Handler75.new(frame)
        # Expected format: 0x00<data>0xFF
        expect(handler.encode_frame).to eq("\x00Hello\xFF".b)
      end
    end

    context 'when frame type is :close' do
      it 'encodes close frame correctly' do
        frame = DummyFrameForHandler75.new(type: :close)
        handler = WebSocket::Frame::Handler::Handler75.new(frame)
        # Expected format: 0xFF0x00
        expect(handler.encode_frame).to eq("\xFF\x00".b)
      end
    end
  end
end
