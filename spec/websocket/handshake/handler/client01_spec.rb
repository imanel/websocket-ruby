# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Handshake::Handler::Client01 do
  let(:client_handshake_v1) do
    WebSocket::Handshake::Client.new(
      url: 'ws://example.com/demo',
      origin: 'http://example.com',
      version: 1
    )
  end

  let(:client_handshake_v3) do
    WebSocket::Handshake::Client.new(
      url: 'ws://example.com/demo',
      origin: 'http://example.com',
      version: 3
    )
  end

  describe '#handshake_keys (via #to_s)' do
    it 'includes Sec-WebSocket-Draft header with version 1' do
      request_string = client_handshake_v1.to_s
      expect(request_string).to include("Sec-WebSocket-Draft: 1\r\n")
    end

    it 'includes Sec-WebSocket-Draft header with version 3' do
      request_string = client_handshake_v3.to_s
      expect(request_string).to include("Sec-WebSocket-Draft: 3\r\n")
    end

    it 'still includes headers from Client75/Client76 (super call)' do
      request_string = client_handshake_v1.to_s
      expect(request_string).to include("Host: example.com\r\n")
      # Corrected case for 'WebSocket' and 'Upgrade'
      expect(request_string).to include("Upgrade: WebSocket\r\n")
      expect(request_string).to include("Connection: Upgrade\r\n")
      expect(request_string).to include("Origin: http://example.com\r\n")
      expect(request_string).to include("Sec-WebSocket-Key1:")
      expect(request_string).to include("Sec-WebSocket-Key2:")
    end
  end
end
