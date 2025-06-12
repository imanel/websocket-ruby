# frozen_string_literal: true

require 'spec_helper'

# Dummy subclass for testing WebSocket::Handshake::Base
class DummyHandshake < WebSocket::Handshake::Base
  # Provide a minimal implementation for methods expected by the Base class tests
  def parse_first_line(line)
    # Do nothing, just to allow parse_data to proceed
  end

  # Override to avoid NotImplementedError for this specific test class
  def should_respond?
    false # Or true, doesn't matter for base class coverage of this line
  end
end

RSpec.describe WebSocket::Handshake::Base do
  describe '#initialize' do
    context 'when a value in args raises TypeError on dup' do
      it 'uses the original value' do
        problematic_value = Object.new
        allow(problematic_value).to receive(:dup).and_raise(TypeError)

        # Initialize with a hash where one value will trigger the rescue
        handshake = WebSocket::Handshake::Base.new(test_param: problematic_value)
        # Check if the instance variable was set to the original object
        expect(handshake.instance_variable_get(:@test_param)).to be problematic_value
      end
    end

    it 'initializes protocols as an empty array if not provided' do
      handshake = WebSocket::Handshake::Base.new
      expect(handshake.protocols).to eq([])
    end

    it 'initializes headers as an empty hash if not provided' do
      handshake = WebSocket::Handshake::Base.new
      expect(handshake.headers).to eq({})
    end
  end

  describe '#should_respond?' do
    it 'raises NotImplementedError' do
      # Need to test on the Base class itself, not the dummy
      expect { WebSocket::Handshake::Base.new.should_respond? }.to raise_error(NotImplementedError)
    end
  end

  describe '#parse_data' do
    let(:handshake) { DummyHandshake.new } # Use dummy for parse_data tests

    context 'when header line is invalid (does not match HEADER regex)' do
      it 'skips the invalid header line and continues' do
        # Add a valid first line (will be handled by dummy parse_first_line)
        # Add an invalid header line
        # Add a valid header line
        # Add the double CRLF to trigger parsing
        handshake << "GET / HTTP/1.1\r\n"
        handshake << "This is an invalid header line\r\n"
        handshake << "Valid-Header: some_value\r\n"
        handshake << "\r\n" # End of headers

        # Calling private method parse_data directly for focused testing.
        # This will cover line 131 (next unless h).
        # It should not raise an error and should set the valid header.
        expect { handshake.send(:parse_data) }.not_to raise_error
        expect(handshake.headers['valid-header']).to eq('some_value')
        expect(handshake.finished?).to be true # parse_data should set state to finished
      end
    end

    context 'when entire header has not been received' do
      it 'returns false and does not change state' do
        handshake << "GET / HTTP/1.1\r\n" # Missing \r\n\r\n
        expect(handshake.send(:parse_data)).to be false
        expect(handshake.finished?).to be false
      end
    end

    context 'when header value is already set and refers to websocket protocol' do
      it 'appends the new value' do
        handshake << "GET / HTTP/1.1\r\n"
        handshake << "Sec-WebSocket-Protocol: chat, superchat\r\n"
        handshake << "Sec-WebSocket-Protocol: additional\r\n"
        handshake << "\r\n"
        handshake.send(:parse_data)
        expect(handshake.headers['sec-websocket-protocol']).to eq('chat, superchat, additional')
      end
    end
  end

  describe '#uri' do
    it 'constructs ws URI correctly' do
      hs = WebSocket::Handshake::Base.new(secure: false, host: 'example.com', port: 80, path: '/chat', query: 'user=test')
      expect(hs.uri).to eq('ws://example.com/chat?user=test')
    end

    it 'constructs wss URI correctly with non-default port' do
      hs = WebSocket::Handshake::Base.new(secure: true, host: 'example.com', port: 8080, path: '/secure')
      expect(hs.uri).to eq('wss://example.com:8080/secure')
    end
  end

  describe '#leftovers' do
    let(:handshake) { DummyHandshake.new }
    it 'returns data after reserved leftover lines' do
        handshake << "GET / HTTP/1.1\r\n"
        handshake << "Header1: Value1\r\n"
        handshake << "\r\n" # End of headers
        handshake << "This is a leftover line.\r\n"
        handshake << "Another leftover line."

        allow(handshake).to receive(:reserved_leftover_lines).and_return(0)
        handshake.send(:parse_data) # Process the handshake

        expect(handshake.leftovers.strip).to eq("This is a leftover line.\r\nAnother leftover line.")
    end

    it 'returns empty string if no leftovers' do
        handshake << "GET / HTTP/1.1\r\n"
        handshake << "\r\n"
        handshake.send(:parse_data)
        expect(handshake.leftovers).to eq('')
    end
  end

end
