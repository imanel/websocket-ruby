# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Frame masking direction' do
  describe WebSocket::Frame::Incoming::Client do
    subject(:frame) { described_class.new(version: 13) }

    it 'never expects frames received from the server to be masked' do
      expect(frame.incoming_masking?).to be false
    end

    it 'masks frames sent to the server according to the handler' do
      expect(frame.outgoing_masking?).to eql frame.instance_variable_get(:@handler).masking?
    end
  end

  describe WebSocket::Frame::Incoming::Server do
    subject(:frame) { described_class.new(version: 13) }

    it 'expects frames received from the client to be masked according to the handler' do
      expect(frame.incoming_masking?).to eql frame.instance_variable_get(:@handler).masking?
    end

    it 'never masks frames sent to the client' do
      expect(frame.outgoing_masking?).to be false
    end
  end

  describe WebSocket::Frame::Outgoing::Client do
    subject(:frame) { described_class.new(version: 13) }

    it 'never expects frames received from the server to be masked' do
      expect(frame.incoming_masking?).to be false
    end

    it 'masks frames sent to the server according to the handler' do
      expect(frame.outgoing_masking?).to eql frame.instance_variable_get(:@handler).masking?
    end
  end

  describe WebSocket::Frame::Outgoing::Server do
    subject(:frame) { described_class.new(version: 13) }

    it 'expects frames received from the client to be masked according to the handler' do
      expect(frame.incoming_masking?).to eql frame.instance_variable_get(:@handler).masking?
    end

    it 'never masks frames sent to the client' do
      expect(frame.outgoing_masking?).to be false
    end
  end
end
