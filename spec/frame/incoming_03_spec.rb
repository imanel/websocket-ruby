# encoding: binary
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Incoming frame draft 03' do
  subject { frame }

  let(:version) { 3 }
  let(:frame) { WebSocket::Frame::Incoming.new(version: version, data: encoded_text) }
  let(:encoded_text) { nil }
  let(:decoded_text) { nil }
  let(:frame_type) { nil }
  let(:error) { nil }

  it_behaves_like 'valid_incoming_frame'

  context 'should properly decode close frame' do
    let(:encoded_text) { "\x01\x05#{decoded_text}" }
    let(:frame_type) { :close }
    let(:decoded_text) { 'Hello' }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should properly decode ping frame' do
    let(:encoded_text) { "\x02\x05#{decoded_text}" }
    let(:frame_type) { :ping }
    let(:decoded_text) { 'Hello' }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should properly decode pong frame' do
    let(:encoded_text) { "\x03\x05#{decoded_text}" }
    let(:frame_type) { :pong }
    let(:decoded_text) { 'Hello' }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should properly decode text frame' do
    let(:encoded_text) { "\x04\x05#{decoded_text}" }
    let(:decoded_text) { 'Hello' }
    let(:frame_type) { :text }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should properly decode text frame with continuation' do
    let(:encoded_text) { "\x84\x03Hel\x00\x02lo" }
    let(:frame_type)   { :text }
    let(:decoded_text) { 'Hello' }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should properly decode text frame in between of continuation' do
    let(:encoded_text) { "\x84\x03Hel\x03\x03abc\x00\x02lo" }
    let(:frame_type)   { %i[pong text] }
    let(:decoded_text) { %w[abc Hello] }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should not return unfinished more frame' do
    let(:encoded_text) { "\x84\x03Hel\x03\x03abc" }
    let(:frame_type)   { :pong }
    let(:decoded_text) { 'abc' }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should properly decode 256 bytes binary frame' do
    let(:encoded_text) { "\x05~\x01\x00#{decoded_text}" }
    let(:frame_type) { :binary }
    let(:decoded_text) { 'a' * 256 }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should properly decode 64KiB binary frame' do
    let(:encoded_text) { "\x05\x7F\x00\x00\x00\x00\x00\x01\x00\x00#{decoded_text}" }
    let(:frame_type) { :binary }
    let(:decoded_text) { 'a' * 65_536 }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should wait with incomplete frame' do
    let(:encoded_text) { "\x04\x06Hello" }
    let(:decoded_text) { nil }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should raise error with invalid opcode' do
    let(:encoded_text) { "\x09\x05Hello" }
    let(:decoded_text) { nil }
    let(:error) { WebSocket::Error::Frame::UnknownOpcode }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should raise error with too long frame' do
    let(:encoded_text) { "\x04\x7F#{'a' * WebSocket.max_frame_size}" }
    let(:decoded_text) { nil }
    let(:error) { WebSocket::Error::Frame::TooLong }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should raise error with continuation frame without more frame earlier' do
    let(:encoded_text) { "\x00\x05Hello" }
    let(:decoded_text) { nil }
    let(:error) { WebSocket::Error::Frame::UnexpectedContinuationFrame }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should raise error with invalid UTF-8 in a standalone text frame' do
    let(:encoded_text) { "\x04\x01\xFF" }
    let(:decoded_text) { nil }
    let(:error) { WebSocket::Error::Frame::InvalidPayloadEncoding }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should raise error with invalid UTF-8 spanning a continuation frame' do
    let(:encoded_text) { "\x84\x01\xE3\x00\x01\x28" }
    let(:decoded_text) { nil }
    let(:error) { WebSocket::Error::Frame::InvalidPayloadEncoding }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should raise error when reserved bits are used' do
    let(:encoded_text) { "\x14\x00" }
    let(:decoded_text) { nil }
    let(:error) { WebSocket::Error::Frame::ReservedBitUsed }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should raise error with a fragmented control frame' do
    let(:encoded_text) { "\x82\x00" }
    let(:decoded_text) { nil }
    let(:error) { WebSocket::Error::Frame::FragmentedControlFrame }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should raise error with a data frame sent instead of a continuation' do
    let(:encoded_text) { "\x84\x03Hel\x04\x02lo" }
    let(:decoded_text) { nil }
    let(:error) { WebSocket::Error::Frame::DataFrameInsteadContinuation }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should raise error with an over-long control frame payload' do
    let(:encoded_text) { "\x02\x7E" }
    let(:decoded_text) { nil }
    let(:error) { WebSocket::Error::Frame::ControlFramePayloadTooLong }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should wait with incomplete extended 16-bit length header' do
    let(:encoded_text) { "\x04\x7E\x00" }
    let(:decoded_text) { nil }

    it_behaves_like 'valid_incoming_frame'
  end

  context 'should wait with incomplete extended 64-bit length header' do
    let(:encoded_text) { "\x04\x7F\x00\x00\x00" }
    let(:decoded_text) { nil }

    it_behaves_like 'valid_incoming_frame'
  end
end
