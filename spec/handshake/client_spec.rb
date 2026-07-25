# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Handshake::Client do
  describe '#initialize' do
    it 'accepts a host directly, without a url or uri' do
      handshake = described_class.new(host: 'example.com')
      expect(handshake.host).to eql('example.com')
    end

    it 'sets an error when no host, url or uri is given' do
      handshake = described_class.new
      expect(handshake.error).to be(:no_host_provided)
    end

    it 'sets an error for an unrecognized protocol version' do
      handshake = described_class.new(host: 'example.com', version: 99)
      expect(handshake.error).to be(:unknown_protocol_version)
    end

    it 'uses the hixie-76-style handler with an added Sec-WebSocket-Draft header for drafts 1-3' do
      handshake = described_class.new(host: 'example.com', version: 2)
      expect(handshake.handler).to be_a(WebSocket::Handshake::Handler::Client01)
      expect(handshake.to_s).to include("Sec-WebSocket-Draft: 2\r\n")
    end
  end

  describe '#should_respond?' do
    it 'is false, as clients never send a response after the handshake' do
      handshake = described_class.new(host: 'example.com')
      expect(handshake.should_respond?).to be false
    end
  end

  describe 'parsing the server response' do
    it 'sets an error when the status line cannot be parsed' do
      handshake = described_class.new(host: 'example.com')
      handshake << "not a status line\r\n\r\n"

      expect(handshake).to be_finished
      expect(handshake.error).to be(:invalid_header)
    end
  end
end
