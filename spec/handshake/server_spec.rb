require 'spec_helper'

describe 'Server handshake' do
  let(:handshake) { WebSocket::Handshake::Server.new }

  shared_examples_for 'all drafts' do
    it "should be valid" do
      handshake << client_request

      handshake.error.should be_nil
      handshake.should be_finished
      handshake.should be_valid
    end

    it "should return valid version" do
      handshake << client_request

      handshake.version.should eql(version)
    end

    it "should return valid host" do
      @request_params = { :host => "www.test.cc" }
      handshake << client_request

      handshake.host.should eql('www.test.cc')
    end

    it "should return valid path" do
      @request_params = { :path => "/custom" }
      handshake << client_request

      handshake.path.should eql('/custom')
    end

    it "should return valid query" do
      @request_params = { :path => "/custom?aaa=bbb" }
      handshake << client_request

      handshake.query.should eql('aaa=bbb')
    end

    it "should return valid port" do
      @request_params = { :port => 123 }
      handshake << client_request

      handshake.port.should eql("123")
    end

    it "should return valid response" do
      validate_request
    end

    it "should allow custom path" do
      @request_params = { :path => "/custom" }
      validate_request
    end

    it "should allow query in path" do
      @request_params = { :path => "/custom?test=true" }
      validate_request
    end

    it "should allow custom port" do
      @request_params = { :port => 123 }
      validate_request
    end
  end

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
