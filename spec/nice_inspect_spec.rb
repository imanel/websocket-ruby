# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::NiceInspect do
  subject(:instance) { klass.new }

  let(:klass) do
    Class.new do
      include WebSocket::NiceInspect

      def initialize
        @foo = 'bar'
      end
    end
  end

  it 'includes the class name and object id' do
    expect(instance.inspect).to match(/\A<#{Regexp.escape(klass.to_s)}:0x\h+ @foo="bar">\z/)
  end

  it 'includes each instance variable and its inspected value' do
    expect(instance.inspect).to include('@foo="bar"')
  end
end
