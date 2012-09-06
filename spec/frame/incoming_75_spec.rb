require 'spec_helper'

describe 'Incoming frame draft 75' do
  let(:version) { 75 }
  let(:frame) { WebSocket::Frame::Incoming.new(:version => version) }
  let(:encoded_text) { "" }
  let(:frame_type) { nil }
  subject { frame }

  it_should_behave_like 'valid_encoded_frame'

  context "with valid text frame" do
    let(:encoded_text) { "\x00abc\xFF" }
    before { frame << encoded_text }

    it "should not return error" do
      subject.next
      subject.error.should be_nil
    end

    it "should return only one valid frame" do
      subject.next
      subject.next.should be_nil
    end

    context "#next" do
      let(:decoded_text) { 'abc' }
      let(:frame_type) { :text }
      subject { frame.next }

      it_should_behave_like 'valid_decoded_frame'
    end
  end

  context "with two frames" do
    let(:encoded_text) { "\x00abc\xFF\x00def\xFF" }
    before { frame << encoded_text }

    it "should not return error after first frame" do
      subject.next
      subject.error.should be_nil
    end

    it "should not return error after second frame" do
      subject.next
      subject.next
      subject.error.should be_nil
    end

    it "should return only two valid frames" do
      subject.next
      subject.next
      subject.next.should be_nil
    end

    context "first frame" do
      let(:decoded_text) { 'abc' }
      let(:frame_type) { :text }
      subject { frame.next }

      it_should_behave_like 'valid_decoded_frame'
    end

    context "second frame" do
      let(:decoded_text) { 'def' }
      let(:frame_type) { :text }
      before  { frame.next }
      subject { frame.next }

      it_should_behave_like 'valid_decoded_frame'
    end
  end

  context "with close frame" do
    let(:encoded_text) { "\xFF\x00" }
    before { frame << encoded_text }

    it "should not return error" do
      subject.next
      subject.error.should be_nil
    end

    it "should return only one valid frame" do
      subject.next
      subject.next.should be_nil
    end

    context "#next" do
      let(:decoded_text) { '' }
      let(:frame_type) { :close }
      subject { frame.next }

      it_should_behave_like 'valid_decoded_frame'
    end
  end

  context "with incomplete frame" do
    let(:encoded_text) { "\x00test" }
    before { frame << encoded_text }

    it "should not return error" do
      subject.next
      subject.error.should be_nil
    end

    it "should return nil for #next" do
      subject.next.should be_nil
    end
  end

  context "with invalid frame" do
    let(:encoded_text) { "invalid" }
    before { frame << encoded_text }

    it "should return error" do
      subject.next
      subject.error.should_not be_nil
      subject.error.should eql(:invalid_frame)
    end

    it "should return nil for #next" do
      subject.next.should be_nil
    end
  end

  context "with too long frame" do
    let(:encoded_text) { "\x00" + "a" * WebSocket::Frame::Handler::Base::MAX_FRAME_SIZE + "\xFF" }
    before { frame << encoded_text }

    it "should return error" do
      subject.next
      subject.error.should_not be_nil
      subject.error.should eql(:frame_too_long)
    end

    it "should return nil for #next" do
      subject.next.should be_nil
    end
  end

end
