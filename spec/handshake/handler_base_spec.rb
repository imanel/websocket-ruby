# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Handshake::Handler::Base do
  subject(:handler) { described_class.new(nil) }

  it 'is valid by default' do
    expect(handler).to be_valid
  end

  it 'renders a blank header line, no headers and a blank finishing line by default' do
    expect(handler.to_s).to eql("\r\n\r\n")
  end
end
