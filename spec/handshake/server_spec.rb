# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe WebSocket::Handshake::Server do
  describe '#should_respond?' do
    it 'is true, as servers always answer a client handshake' do
      expect(described_class.new.should_respond?).to be true
    end
  end

  describe 'parsing the client request' do
    it 'sets an error for an unrecognized protocol version' do
      handshake = described_class.new
      handshake << "GET /demo HTTP/1.1\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n" \
                   "Host: example.com\r\nSec-WebSocket-Version: 999\r\n\r\n"

      expect(handshake).to be_finished
      expect(handshake.error).to be(:unknown_protocol_version)
    end

    it 'sets an error when the request line cannot be parsed' do
      handshake = described_class.new
      handshake << "not a request line\r\n\r\n"

      expect(handshake).to be_finished
      expect(handshake.error).to be(:invalid_header)
    end

    it 'falls back to the legacy Sec-WebSocket-Draft header when Sec-WebSocket-Version is absent' do
      handshake = described_class.new
      handshake << "GET /demo HTTP/1.1\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n" \
                   "Host: example.com\r\nSec-WebSocket-Draft: 4\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n\r\n"

      expect(handshake.version).to be(4)
    end
  end

  describe '#from_rack' do
    let(:base_env) do
      {
        'REQUEST_PATH' => '/demo',
        'QUERY_STRING' => '',
        'HTTP_SEC_WEBSOCKET_KEY1' => '4 @1  46546xW%0l 1 5',
        'HTTP_SEC_WEBSOCKET_KEY2' => '12998 5 Y3 1  .P00'
      }
    end

    it 'reads the body via #readpartial when available' do
      handshake = described_class.new
      handshake.from_rack(base_env.merge('rack.input' => StringIO.new('body-via-readpartial')))

      expect(handshake.instance_variable_get(:@leftovers)).to eql('body-via-readpartial')
    end

    it 'falls back to #read when #readpartial is unavailable' do
      input = Class.new do
        def read
          'body-via-read'
        end
      end.new
      handshake = described_class.new
      handshake.from_rack(base_env.merge('rack.input' => input))

      expect(handshake.instance_variable_get(:@leftovers)).to eql('body-via-read')
    end

    it 'falls back to #to_s when neither #readpartial nor #read is available' do
      input = Class.new do
        def to_s
          'body-via-to_s'
        end
      end.new
      handshake = described_class.new
      handshake.from_rack(base_env.merge('rack.input' => input))

      expect(handshake.instance_variable_get(:@leftovers)).to eql('body-via-to_s')
    end
  end
end
