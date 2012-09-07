shared_examples_for 'valid_outgoing_frame' do
  its(:class) { should eql(WebSocket::Frame::Outgoing) }
  its(:version) { should eql(version) }
  its(:type) { should eql(frame_type) }
  its(:error) { should be_nil }
  its(:data) { should eql(decoded_text) }
  its(:to_s) { should eql(encoded_text) }
  its(:require_sending?) { should eql(require_sending) }
end
