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

    it "should disallow request without spaces in key 1" do
      @request_params = { :key1 => "4@146546xW%0l15" }
      handshake << client_request

      handshake.should be_finished
      handshake.should_not be_valid
      handshake.error.should eql('Websocket Key1 or Key2 does not contain spaces - this is a symptom of a cross-protocol attack')
    end

    it "should disallow request without spaces in key 2" do
      @request_params = { :key2 => "129985Y31.P00" }
      handshake << client_request

      handshake.should be_finished
      handshake.should_not be_valid
      handshake.error.should eql('Websocket Key1 or Key2 does not contain spaces - this is a symptom of a cross-protocol attack')
    end

    it "should disallow request with invalid number of spaces or numbers in key 1" do
      @request_params = { :key1 => "4 @1   46546xW%0l 1 5" }
      handshake << client_request

      handshake.should be_finished
      handshake.should_not be_valid
      handshake.error.should eql("Invalid Key #{@request_params[:key1].inspect}")
    end

    it "should disallow request with invalid number of spaces or numbers in key 2" do
      @request_params = { :key2 => "12998  5 Y3 1  .P00" }
      handshake << client_request

      handshake.should be_finished
      handshake.should_not be_valid
      handshake.error.should eql("Invalid Key #{@request_params[:key2].inspect}")
    end
  end

  context "draft 04" do
    let(:version) { 04 }
    let(:client_request) { client_handshake_04(@request_params || {}) }
    let(:server_response) { server_handshake_04(@request_params || {}) }

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
