# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Handshake::Server do

  describe '#from_rack for version 76' do
    let(:env_base) do
      {
        'REQUEST_PATH' => '/ws',
        'QUERY_STRING' => '',
        'HTTP_HOST' => 'example.com',
        'HTTP_UPGRADE' => 'websocket',
        'HTTP_CONNECTION' => 'Upgrade',
        'HTTP_SEC_WEBSOCKET_KEY1' => '4 @1  46546xW%0l 1 5',
        'HTTP_SEC_WEBSOCKET_KEY2' => '12998 5 Y3 1  .P00',
        'HTTP_ORIGIN' => 'http://example.com'
      }
    end
    let(:key3_body) { 'abcdefgh' }

    context 'when rack.input responds to readpartial' do
      it 'uses readpartial and sets leftovers' do
        mock_input = double('rack.input')
        allow(mock_input).to receive(:respond_to?).with(:readpartial).and_return(true)
        allow(mock_input).to receive(:readpartial).and_return(key3_body)
        env = env_base.merge('rack.input' => mock_input)
        current_handshake = WebSocket::Handshake::Server.new(query: 'init_query=1')
        current_handshake.from_rack(env)
        expect(current_handshake.version).to eq(76)
        expect(current_handshake.instance_variable_get(:@leftovers)).to eq(key3_body)
      end
    end

    context 'when rack.input does not respond to readpartial but responds to read (covers lines 94, 95)' do
      it 'uses read and sets leftovers' do
        mock_input = double('rack.input')
        allow(mock_input).to receive(:respond_to?).with(:readpartial).and_return(false)
        allow(mock_input).to receive(:respond_to?).with(:read).and_return(true)
        allow(mock_input).to receive(:read).and_return(key3_body)
        env = env_base.merge('rack.input' => mock_input)
        current_handshake = WebSocket::Handshake::Server.new(query: 'init_query=1')
        current_handshake.from_rack(env)
        expect(current_handshake.version).to eq(76)
        expect(current_handshake.instance_variable_get(:@leftovers)).to eq(key3_body)
      end
    end

    context 'when rack.input only responds to to_s (covers line 97)' do
      it 'uses to_s and sets leftovers' do
        mock_input = double('rack.input')
        allow(mock_input).to receive(:respond_to?).with(:readpartial).and_return(false)
        allow(mock_input).to receive(:respond_to?).with(:read).and_return(false)
        allow(mock_input).to receive(:to_s).and_return(key3_body)
        env = env_base.merge('rack.input' => mock_input)
        current_handshake = WebSocket::Handshake::Server.new(query: 'init_query=1')
        current_handshake.from_rack(env)
        expect(current_handshake.version).to eq(76)
        expect(current_handshake.instance_variable_get(:@leftovers)).to eq(key3_body)
      end
    end
  end

  describe '#from_hash' do
    it 'sets leftovers from :body if provided (covers line 126)' do
      test_body = "some_body_data_for_leftovers"
      hs = WebSocket::Handshake::Server.new(version: 4, host: 'h.c', path: '/p')
      hs.from_hash(path: '/test', headers: {}, body: test_body)
      expect(hs.instance_variable_get(:@leftovers)).to eq(test_body)
      expect(hs.version).to eq(4) # Version remains 4 as it's not nil/false
      expect(hs.error).to be_nil
    end

    it 'defaults path and query, version remains from init' do
      hs = WebSocket::Handshake::Server.new(version: 4, host: 'h.c', path: '/p')
      hs.from_hash({}) # Empty headers, so set_version doesn't change @version
      expect(hs.path).to eq('/')
      expect(hs.query).to eq('')
      expect(hs.version).to eq(4) # Version remains 4
      expect(hs.error).to be_nil
    end
  end

  describe '#set_version' do
    it 'defaults to version 75 if no version headers are present and @version is nil (covers line 159)' do
      hs = WebSocket::Handshake::Server.new # @version is nil initially due to Base#initialize
      hs.instance_variable_set(:@version, nil) # Explicitly ensure @version is nil
      hs.instance_variable_set(:@headers, {})
      hs.send(:set_version)
      expect(hs.version).to eq(75)
      expect(hs.instance_variable_get(:@handler)).to be_a(WebSocket::Handshake::Handler::Server75)
      expect(hs.error).to be_nil
    end

    it 'sets version from sec-websocket-version' do
        hs = WebSocket::Handshake::Server.new
        hs.instance_variable_set(:@headers, {'sec-websocket-version' => '8'})
        hs.send(:set_version)
        expect(hs.version).to eq(8)
        expect(hs.instance_variable_get(:@handler)).to be_a(WebSocket::Handshake::Handler::Server04)
    end

    it 'sets version from sec-websocket-draft' do
        hs = WebSocket::Handshake::Server.new
        hs.instance_variable_set(:@headers, {'sec-websocket-draft' => '2'})
        hs.send(:set_version)
        expect(hs.version).to eq(2)
        expect(hs.instance_variable_get(:@handler)).to be_a(WebSocket::Handshake::Handler::Server76)
    end

    it 'sets version to 76 if sec-websocket-key1 is present' do
        hs = WebSocket::Handshake::Server.new(query: 'needed_for_v76_handler_init')
        hs.instance_variable_set(:@headers, {'sec-websocket-key1' => 'somekey'})
        hs.send(:set_version)
        expect(hs.version).to eq(76)
        expect(hs.instance_variable_get(:@handler)).to be_a(WebSocket::Handshake::Handler::Server76)
    end
  end

  describe '#host and #port' do
    it 'extracts host and port correctly' do
      hs = WebSocket::Handshake::Server.new
      hs.instance_variable_set(:@headers, {'host' => 'my.server.com:8080'})
      expect(hs.host).to eq('my.server.com')
      expect(hs.port).to eq(8080)
    end

    it 'extracts host and uses default port if not specified' do
      hs = WebSocket::Handshake::Server.new
      hs.instance_variable_set(:@headers, {'host' => 'my.server.com'})
      expect(hs.host).to eq('my.server.com')
      expect(hs.port).to eq(80)
    end
  end

  describe '#parse_first_line' do
    it 'parses valid GET request' do
        hs = WebSocket::Handshake::Server.new
        expect { hs.send(:parse_first_line, "GET /chat?user=foo HTTP/1.1") }.not_to raise_error
        expect(hs.path).to eq('/chat')
        expect(hs.query).to eq('user=foo')
    end

    it 'raises InvalidHeader for malformed request line' do
        hs = WebSocket::Handshake::Server.new
        expect { hs.send(:parse_first_line, "INVALID REQUEST") }.to raise_error(WebSocket::Error::Handshake::InvalidHeader)
    end

    it 'raises GetRequestRequired for non-GET method' do
        hs = WebSocket::Handshake::Server.new
        expect { hs.send(:parse_first_line, "POST / HTTP/1.1") }.to raise_error(WebSocket::Error::Handshake::GetRequestRequired)
    end
  end

end
