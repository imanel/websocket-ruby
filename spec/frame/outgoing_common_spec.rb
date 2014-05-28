# encoding: binary
require 'spec_helper'

describe 'Outgoing common frame' do
  subject { WebSocket::Frame::Outgoing.new }

  its(:version) { should eql(13) }
  its(:error?) { should be false }

  it 'should raise error on invalid version' do
    subject = WebSocket::Frame::Incoming.new(:version => 70)
    expect(subject.error?).to be true
    expect(subject.error).to eql(:unknown_protocol_version)
  end
end
