shared_examples_for 'valid_incoming_frame' do
  its(:class) { should eql(WebSocket::Frame::Incoming) }
  its(:version) { should eql(version) }
  its(:type) { should eql(frame_type) }
  its(:error) { should be_nil }
  its(:next) { should be_nil }
end

shared_examples_for 'valid_encoded_frame' do
  it_should_behave_like 'valid_incoming_frame'

  its(:decoded?) { should be_false }
  its(:to_s) { should eql(encoded_text) }
end

shared_examples_for 'valid_decoded_frame' do
  it_should_behave_like 'valid_incoming_frame'

  its(:decoded?) { should be_true }
  its(:to_s) { should eql(decoded_text) }
end
