# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Frame::Handler::Base do
  subject(:handler) { described_class.new(nil) }

  describe '#encode_frame' do
    it 'is abstract and must be implemented by subclasses' do
      expect { handler.encode_frame }.to raise_error(NotImplementedError)
    end
  end

  describe '#decode_frame' do
    it 'is abstract and must be implemented by subclasses' do
      expect { handler.decode_frame }.to raise_error(NotImplementedError)
    end
  end
end
