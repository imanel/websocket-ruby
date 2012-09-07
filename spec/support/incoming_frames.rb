shared_examples_for 'valid_incoming_frame' do
  let(:decoded_text_array) { Array(decoded_text) }
  let(:frame_type_array) { Array(frame_type) }

  its(:class) { should eql(WebSocket::Frame::Incoming) }
  its(:data) { should eql(encoded_text || "") }
  its(:version) { should eql(version) }
  its(:type) { should be_nil }
  its(:decoded?) { should be_false }
  its(:to_s) { should eql(encoded_text || "") }

  it "should have specified number of returned frames" do
    decoded_text_array.each_with_index do |da, index|
      subject.next.should_not be_nil, "Should return frame for #{da}, #{frame_type_array[index]}"
    end
    subject.next.should be_nil
    subject.error.should eql(error)
  end

  it "should return valid decoded frame for each specified decoded texts" do
    decoded_text_array.each_with_index do |da, index|
      f = subject.next
      f.decoded?.should be_true
      f.type.should eql(frame_type_array[index])
      f.to_s.should eql(da)
    end
  end
end
