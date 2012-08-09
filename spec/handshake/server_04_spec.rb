require 'spec_helper'

describe 'Server draft 04 handshake' do
  let(:handshake) { WebSocket::Handshake::Server.new }
  let(:version) { 04 }
  let(:client_request) { client_handshake_04(@request_params || {}) }
  let(:server_response) { server_handshake_04(@request_params || {}) }

  it_should_behave_like 'all drafts'
end
