# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Frame::Base do
  let(:default_frame) { WebSocket::Frame::Base.new } # Uses DEFAULT_VERSION

  describe '#supported_frames' do
    it 'raises NotImplementedError' do
      expect { default_frame.supported_frames }.to raise_error(NotImplementedError)
    end
  end

  describe '#initialize' do
    context 'with version 0' do
      it 'initializes with Handler::Handler75 and no error' do
        frame_v0 = WebSocket::Frame::Base.new(version: 0)
        expect(frame_v0.error).to be_nil # Check that @error is nil (no error occurred)
        expect(frame_v0.instance_variable_get(:@handler)).to be_a(WebSocket::Frame::Handler::Handler75)
      end
    end

    context 'with version 1 (as another example for 0..2 range)' do
      it 'initializes with Handler::Handler75 and no error' do
        frame_v1 = WebSocket::Frame::Base.new(version: 1)
        expect(frame_v1.error).to be_nil
        expect(frame_v1.instance_variable_get(:@handler)).to be_a(WebSocket::Frame::Handler::Handler75)
      end
    end

    context 'with an unknown version (e.g., 99)' do
      it 'sets the error to :unknown_protocol_version' do
        frame_unknown = WebSocket::Frame::Base.new(version: 99)
        expect(frame_unknown.error?).to be true # @error is not nil
        expect(frame_unknown.error).to eq(:unknown_protocol_version) # @error is the symbol
      end
    end

    context 'with default version' do
      it 'initializes with a handler and no error' do
        expect(default_frame.error).to be_nil
        expect(default_frame.instance_variable_get(:@handler)).not_to be_nil
      end
    end
  end
end
