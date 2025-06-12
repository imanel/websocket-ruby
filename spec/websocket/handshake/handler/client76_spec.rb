# frozen_string_literal: true

require 'spec_helper'
require 'digest/md5'

RSpec.describe WebSocket::Handshake::Handler::Client76 do
  let(:handshake_client_instance) do # Renamed to avoid conflict with RSpec's `client`
    WebSocket::Handshake::Client.new(
      url: 'ws://example.com/demo',
      origin: 'http://example.com',
      version: 76 # This ensures Client76 handler is used
    )
  end
  let(:handler) { handshake_client_instance.instance_variable_get(:@handler) }

  # Helper to construct the server's expected challenge response
  def construct_expected_challenge(key1_num, key2_num, key3_val)
    sum = [key1_num].pack('N*') +
          [key2_num].pack('N*') +
          key3_val
    Digest::MD5.digest(sum) # Should be 16 bytes
  end

  describe '#reserved_leftover_lines' do
    it 'returns 1 (covers line 18)' do
      # Directly test the private method on the handler instance
      expect(handler.send(:reserved_leftover_lines)).to eq(1)
    end
  end

  # Test related to the original attempt to cover reserved_leftover_lines via valid? and leftovers
  describe 'handshake process affecting leftovers' do
    it 'completes a valid handshake and checks leftovers (indirectly related to reserved_leftover_lines)' do
      client_request_string = handshake_client_instance.to_s

      key1_val = handler.send(:key1)
      key2_val = handler.send(:key2)
      key3_val = handler.send(:key3)

      key1_number = handler.instance_variable_get(:@key1_number)
      key2_number = handler.instance_variable_get(:@key2_number)

      expected_challenge_response = construct_expected_challenge(key1_number, key2_number, key3_val)

      server_response = [
        "HTTP/1.1 101 WebSocket Protocol Handshake",
        "Upgrade: WebSocket",
        "Connection: Upgrade",
        "Sec-WebSocket-Origin: #{handshake_client_instance.origin}",
        "Sec-WebSocket-Location: #{handshake_client_instance.uri}",
        "",
        expected_challenge_response
      ].join("\r\n")

      handshake_client_instance << server_response

      expect(handshake_client_instance.finished?).to be true
      expect(handshake_client_instance.error).to be_nil
      expect(handshake_client_instance.valid?).to be true

      # This call to leftovers on the Handshake::Client instance uses Handshake::Base#reserved_leftover_lines,
      # not Handler::Client76#reserved_leftover_lines.
      expect(handshake_client_instance.leftovers).to eq(expected_challenge_response)
    end
  end

  describe '#valid?' do
    it 'returns false if challenge is incorrect' do
      client_request_string = handshake_client_instance.to_s # generate keys

      incorrect_challenge = "1234567890123456" # 16 bytes, but wrong

      server_response = [
        "HTTP/1.1 101 WebSocket Protocol Handshake",
        "Upgrade: WebSocket",
        "Connection: Upgrade",
        "Sec-WebSocket-Origin: #{handshake_client_instance.origin}",
        "Sec-WebSocket-Location: #{handshake_client_instance.uri}",
        "",
        incorrect_challenge
      ].join("\r\n")

      handshake_client_instance << server_response
      expect(handshake_client_instance.valid?).to be false
      expect(handshake_client_instance.error).to eq(:invalid_handshake_authentication)
    end
  end
end
