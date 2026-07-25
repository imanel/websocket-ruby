# encoding: binary
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Frame::Data do
  describe '#set_mask' do
    it 'raises MaskTooShort when fewer than 4 bytes are available' do
      data = described_class.new('ab')
      expect { data.set_mask }.to raise_error(WebSocket::Error::Frame::MaskTooShort)
    end

    it 'uses the first 4 bytes as masking key for subsequent unmasking' do
      mask = [0x11, 0x22, 0x33, 0x44]
      masked_payload = 'Hi'.bytes.each_with_index.map { |byte, i| byte ^ mask[i % 4] }.pack('C*')
      data = described_class.new(mask.pack('C*') + masked_payload)

      data.set_mask
      expect(data.getbytes(4, 2)).to eql('Hi')
    end

    it 'leaves data unmasked when unset_mask is called' do
      data = described_class.new('abcd')
      data.set_mask
      data.unset_mask
      expect(data.getbytes(0, 4)).to eql('abcd')
    end
  end

  describe '#mask' do
    let(:data) { described_class.new('') }

    it 'XORs each byte with the mask when no native implementation is available' do
      expect(data.mask([0b1010, 0b0101], [0b1111, 0b1111])).to eql([0b0101, 0b1010])
    end

    it 'delegates to a native implementation when available' do
      def data.mask_native(payload, mask)
        [:native, payload, mask]
      end

      expect(data.mask([1, 2], [3, 4])).to eql([:native, [1, 2], [3, 4]])
    end
  end
end
