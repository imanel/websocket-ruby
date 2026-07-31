# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Handshake::Base do
  describe '#initialize' do
    it 'duplicates initializer values so callers cannot mutate internal state' do
      host = 'example.com'.dup
      handshake = described_class.new(host: host)
      host << '.evil'

      expect(handshake.host).to eql('example.com')
    end

    it 'falls back to the original object when it cannot be duplicated' do
      undupable = Class.new do
        def dup
          raise TypeError, "can't dup"
        end
      end.new

      expect { described_class.new(custom: undupable) }.not_to raise_error
    end
  end

  describe '#should_respond?' do
    it 'is abstract and must be implemented by subclasses' do
      expect { described_class.new.should_respond? }.to raise_error(NotImplementedError)
    end
  end

  describe '#to_s' do
    it 'returns an empty string when no handler has been selected yet' do
      expect(described_class.new.to_s).to eql('')
    end
  end

  describe 'secure handshakes' do
    subject(:handshake) { WebSocket::Handshake::Client.new(host: 'example.com', secure: true) }

    it 'defaults to port 443' do
      expect(handshake.default_port).to be(443)
    end

    it 'builds a wss:// uri' do
      expect(handshake.uri).to start_with('wss://')
    end
  end

  describe 'parsing headers' do
    it 'skips lines that are not valid HTTP headers' do
      request = <<-REQUEST
GET /demo HTTP/1.1\r
Upgrade: websocket\r
this is not a valid header line\r
Connection: Upgrade\r
Host: example.com\r
Sec-WebSocket-Version: 13\r
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r
\r
      REQUEST

      handshake = WebSocket::Handshake::Server.new
      handshake << request

      expect(handshake).to be_valid
      expect(handshake.headers).not_to have_key('this is not a valid header line')
    end
  end

  describe 'merging repeated protocol headers' do
    it 'joins repeated Sec-WebSocket-Protocol header lines instead of overwriting them' do
      request = <<-REQUEST
GET /demo HTTP/1.1\r
Upgrade: websocket\r
Connection: Upgrade\r
Host: example.com\r
Sec-WebSocket-Version: 13\r
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r
Sec-WebSocket-Protocol: foo\r
Sec-WebSocket-Protocol: bar\r
\r
      REQUEST

      handshake = WebSocket::Handshake::Server.new
      handshake << request

      expect(handshake.headers['sec-websocket-protocol']).to eql('foo, bar')
    end
  end
end
