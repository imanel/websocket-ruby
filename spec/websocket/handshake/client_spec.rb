# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Handshake::Client do
  let(:default_args) { { host: 'example.com' } }

  describe '#initialize' do
    it 'handles version 1..3 correctly (line 110)' do
      handshake = WebSocket::Handshake::Client.new(default_args.merge(version: 2))
      expect(handshake.error).to be_nil
      expect(handshake.instance_variable_get(:@handler)).to be_a(WebSocket::Handshake::Handler::Client01)
    end

    it 'sets error to :unknown_protocol_version for an unsupported version (line 113)' do
      handshake = WebSocket::Handshake::Client.new(default_args.merge(version: 99))
      expect(handshake.error).to eq(:unknown_protocol_version) # Check the symbol directly
    end

    it 'handles version 75 correctly' do
      handshake = WebSocket::Handshake::Client.new(default_args.merge(version: 75))
      expect(handshake.error).to be_nil
      expect(handshake.instance_variable_get(:@handler)).to be_a(WebSocket::Handshake::Handler::Client75)
    end

    it 'handles version 76 or 0 correctly' do
      handshake0 = WebSocket::Handshake::Client.new(default_args.merge(version: 0))
      expect(handshake0.error).to be_nil
      expect(handshake0.instance_variable_get(:@handler)).to be_a(WebSocket::Handshake::Handler::Client76)

      handshake76 = WebSocket::Handshake::Client.new(default_args.merge(version: 76))
      expect(handshake76.error).to be_nil
      expect(handshake76.instance_variable_get(:@handler)).to be_a(WebSocket::Handshake::Handler::Client76)
    end

    it 'handles version 4..10 correctly' do
      handshake = WebSocket::Handshake::Client.new(default_args.merge(version: 7))
      expect(handshake.error).to be_nil
      expect(handshake.instance_variable_get(:@handler)).to be_a(WebSocket::Handshake::Handler::Client04)
    end

    it 'handles version 11..17 correctly' do
      handshake = WebSocket::Handshake::Client.new(default_args.merge(version: 13)) # Default version
      expect(handshake.error).to be_nil
      expect(handshake.instance_variable_get(:@handler)).to be_a(WebSocket::Handshake::Handler::Client11)
    end

    context 'when path is nil or empty' do
      it 'defaults path to "/"' do
        handshake_nil_path = WebSocket::Handshake::Client.new(default_args.merge(path: nil))
        expect(handshake_nil_path.path).to eq('/')
        handshake_empty_path = WebSocket::Handshake::Client.new(default_args.merge(path: ''))
        expect(handshake_empty_path.path).to eq('/')
      end
    end

    context 'when host is not provided' do
      it 'sets error to :no_host_provided' do
        handshake = WebSocket::Handshake::Client.new({})
        expect(handshake.error).to eq(:no_host_provided) # Check the symbol directly
      end
    end

    context 'when url is provided' do
      it 'parses url correctly for ws scheme' do
        handshake = WebSocket::Handshake::Client.new(url: 'ws://example.com:1234/chat?user=test')
        expect(handshake.secure).to be false
        expect(handshake.host).to eq('example.com')
        expect(handshake.port).to eq(1234)
        expect(handshake.path).to eq('/chat')
        expect(handshake.query).to eq('user=test')
      end

      it 'parses url correctly for wss scheme and default port' do
        handshake = WebSocket::Handshake::Client.new(url: 'wss://secure.example.com/token')
        expect(handshake.secure).to be true
        expect(handshake.host).to eq('secure.example.com')
        expect(handshake.port).to eq(443) # Default for wss
        expect(handshake.path).to eq('/token')
        expect(handshake.query).to be_nil
      end
    end
  end

  describe '#should_respond?' do
    it 'returns false (line 99)' do
      handshake = WebSocket::Handshake::Client.new(default_args)
      expect(handshake.should_respond?).to be false
    end
  end

  describe '#<<' do
    let(:handshake) { WebSocket::Handshake::Client.new(default_args.merge(version: 13)) }

    it 'appends data and calls parse_data' do
      expect(handshake).to receive(:parse_data).once
      handshake << "some server data"
      expect(handshake.instance_variable_get(:@data)).to end_with("some server data")
    end
  end

  describe '#parse_first_line' do
    let(:handshake) { WebSocket::Handshake::Client.new(default_args) }

    it 'parses valid HTTP 101 response' do
        expect { handshake.send(:parse_first_line, "HTTP/1.1 101 Switching Protocols") }.not_to raise_error
    end

    it 'raises InvalidHeader for non-HTTP response' do
      expect { handshake.send(:parse_first_line, "NOT HTTP") }.to raise_error(WebSocket::Error::Handshake::InvalidHeader)
    end

    it 'raises InvalidStatusCode for non-101 status' do
        expect { handshake.send(:parse_first_line, "HTTP/1.1 200 OK") }.to raise_error(WebSocket::Error::Handshake::InvalidStatusCode)
    end
  end

end
