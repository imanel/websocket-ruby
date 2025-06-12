# frozen_string_literal: true

require 'spec_helper'
require 'websocket/handshake/handler/client76' # For NOISE_CHARS

RSpec.describe WebSocket::Handshake::Handler::Server76 do

  NOISE_CHARS_DEFINED = defined?(WebSocket::Handshake::Handler::Client76::NOISE_CHARS)
  NOISE_CHARS = if NOISE_CHARS_DEFINED
                  WebSocket::Handshake::Handler::Client76::NOISE_CHARS
                else
                  (("\x21".."\x2f").to_a + ("\x3a".."\x7e").to_a) # Corrected fallback
                end

  def create_test_key(number_char, number_of_digits, num_spaces)
    num_str = number_char * number_of_digits
    key = num_str
    num_spaces.times do |i|
      pos = ((key.length / (num_spaces + 1).to_f) * (i + 1)).to_i
      key.insert(pos, ' ')
    end
    rand(1..5).times do
      noise_char = NOISE_CHARS.sample
      pos = rand(key.length + 1)
      key.insert(pos, noise_char)
    end
    key
  end

  let(:minimal_server_opts) { { version: 76, host: 'example.com', path: '/ws', query: 'q=1' } }

  describe '#reserved_leftover_lines' do
    it 'returns 1 directly (covers line 26 in Server76 file)' do
      server_instance = WebSocket::Handshake::Server.new(minimal_server_opts)
      expect(server_instance.error).to be_nil, "Server initialization failed with error: #{server_instance.error.inspect}"
      handler_instance = server_instance.instance_variable_get(:@handler)
      expect(handler_instance).to be_a(WebSocket::Handshake::Handler::Server76), "Handler was not a Server76 instance, was: #{handler_instance.inspect}"
      expect(handler_instance.send(:reserved_leftover_lines)).to eq(1)
    end
  end

  context 'with full client interaction' do
    let(:handshake_server_opts_for_interaction) { { version: 76, host: 'example.com', path: '/ws', query: 'dummyquery=0' } }
    let(:handshake_server_for_interaction) { WebSocket::Handshake::Server.new(handshake_server_opts_for_interaction) }

    it 'is covered when processing a valid client handshake and checking leftovers' do
      key1_val = create_test_key('2', 4, 2)
      key2_val = create_test_key('3', 6, 3)
      client_key3_body = "abcdefgh"

      client_request = [
        "GET /ws?dummyquery=0 HTTP/1.1",
        "Host: example.com",
        "Upgrade: websocket",
        "Connection: Upgrade",
        "Sec-WebSocket-Key1: #{key1_val}",
        "Sec-WebSocket-Key2: #{key2_val}",
        "Origin: http://example.com",
        "",
        client_key3_body
      ].join("\r\n")

      handshake_server_for_interaction << client_request

      expect(handshake_server_for_interaction.finished?).to be true
      expect(handshake_server_for_interaction.error).to be_nil
      expect(handshake_server_for_interaction.valid?).to be true
      expect(handshake_server_for_interaction.leftovers).to eq(client_key3_body)
    end

    it 'returns false if key1 numbers are not divisible by spaces (testing valid? behavior)' do
      key1_invalid = "1 2 3 a"
      key2_valid = create_test_key('3', 6, 3)
      client_key3_body = "abcdefgh"

      client_request = [
        "GET /ws?dummyquery=0 HTTP/1.1",
        "Host: example.com",
        "Upgrade: websocket",
        "Connection: Upgrade",
        "Sec-WebSocket-Key1: #{key1_invalid}",
        "Sec-WebSocket-Key2: #{key2_valid}",
        "Origin: http://example.com",
        "",
        client_key3_body # Corrected typo from client_key3__body
      ].join("\r\n")
      handshake_server_for_interaction << client_request

      expect(handshake_server_for_interaction.valid?).to be false
      expect(handshake_server_for_interaction.error).to eq(:invalid_handshake_authentication)
    end

    it 'returns false if key has no spaces (testing valid? behavior)' do
      key1_no_spaces = "12345abc"
      key2_valid = create_test_key('3', 6, 3)
      client_key3_body = "abcdefgh"

      client_request = [
        "GET /ws?dummyquery=0 HTTP/1.1",
        "Host: example.com",
        "Upgrade: websocket",
        "Connection: Upgrade",
        "Sec-WebSocket-Key1: #{key1_no_spaces}",
        "Sec-WebSocket-Key2: #{key2_valid}",
        "Origin: http://example.com",
        "",
        client_key3_body
      ].join("\r\n")
      handshake_server_for_interaction << client_request
      expect(handshake_server_for_interaction.valid?).to be false
      expect(handshake_server_for_interaction.error).to eq(:invalid_handshake_authentication)
    end
  end
end
