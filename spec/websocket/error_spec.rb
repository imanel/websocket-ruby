# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Error do
  describe WebSocket::Error::Frame do
    it 'ControlFramePayloadTooLong returns correct message' do # Covers line 8
      expect(WebSocket::Error::Frame::ControlFramePayloadTooLong.new.message).to eq(:control_frame_payload_too_long)
    end

    it 'DataFrameInsteadContinuation returns correct message' do # Covers line 14
      expect(WebSocket::Error::Frame::DataFrameInsteadContinuation.new.message).to eq(:data_frame_instead_continuation)
    end

    it 'FragmentedControlFrame returns correct message' do # Covers line 20
      expect(WebSocket::Error::Frame::FragmentedControlFrame.new.message).to eq(:fragmented_control_frame)
    end

    it 'MaskTooShort returns correct message' do # Covers line 38
      expect(WebSocket::Error::Frame::MaskTooShort.new.message).to eq(:mask_is_too_short)
    end

    it 'ReservedBitUsed returns correct message' do # Covers line 44
      expect(WebSocket::Error::Frame::ReservedBitUsed.new.message).to eq(:reserved_bit_used)
    end
  end

  describe WebSocket::Error::Handshake do
    it 'InvalidAuthentication returns correct message' do # Covers line 100
      error_instance = WebSocket::Error::Handshake::InvalidAuthentication.new
      expect(error_instance.message).to eq(:invalid_handshake_authentication)
    end

    it 'InvalidStatusCode returns correct message' do # Covers line 118
      expect(WebSocket::Error::Handshake::InvalidStatusCode.new.message).to eq(:invalid_status_code)
    end

    it 'NoHostProvided returns correct message' do # Covers line 124
      error_instance = WebSocket::Error::Handshake::NoHostProvided.new
      expect(error_instance.message).to eq(:no_host_provided)
    end
  end
end
