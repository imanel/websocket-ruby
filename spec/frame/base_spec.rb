# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Frame::Base do
  describe '#supported_frames' do
    it 'is abstract and must be implemented by subclasses' do
      frame = described_class.new
      expect { frame.supported_frames }.to raise_error(NotImplementedError)
    end
  end

  describe '#include_version' do
    {
      0 => WebSocket::Frame::Handler::Handler75,
      1 => WebSocket::Frame::Handler::Handler75,
      2 => WebSocket::Frame::Handler::Handler75,
      75 => WebSocket::Frame::Handler::Handler75,
      76 => WebSocket::Frame::Handler::Handler75,
      3 => WebSocket::Frame::Handler::Handler03,
      4 => WebSocket::Frame::Handler::Handler04,
      5 => WebSocket::Frame::Handler::Handler05,
      6 => WebSocket::Frame::Handler::Handler05,
      7 => WebSocket::Frame::Handler::Handler07,
      13 => WebSocket::Frame::Handler::Handler07
    }.each do |version, handler_class|
      it "uses #{handler_class} for protocol version #{version}" do
        frame = described_class.new(version: version)
        expect(frame.instance_variable_get(:@handler)).to be_a(handler_class)
      end
    end
  end
end
