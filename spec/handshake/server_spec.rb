require 'spec_helper'

describe 'Server handshake' do
  let(:handshake) { WebSocket::Handshake::Server.new }

  context "draft 75" do
    let(:version) { 75 }
    let(:client_request) { client_handshake_75(@request_params || {}) }
    let(:server_response) { server_handshake_75(@request_params || {}) }

    it_should_behave_like 'all drafts'
  end

  context "draft 76" do
    let(:version) { 76 }
    let(:client_request) { client_handshake_76(@request_params || {}) }
    let(:server_response) { server_handshake_76(@request_params || {}) }

    it_should_behave_like 'all drafts'
  end

  # context "draft 04" do
  #   let(:version) { 06 }
  #   let(:client_request) { client_handshake_04(@request_params || {}) }
  #   let(:server_response) { server_handshake_04(@request_params || {}) }

  #   it_should_behave_like 'all drafts'
  # end

  context "draft 06" do
    let(:version) { 06 }
    let(:client_request) { client_handshake_06(@request_params || {}) }
    let(:server_response) { server_handshake_06(@request_params || {}) }

    it_should_behave_like 'all drafts'
  end

  def validate_request
    handshake << client_request

    handshake.error.should be_nil
    handshake.should be_finished
    handshake.should be_valid
    handshake.to_s.should eql(server_response)
  end

end
