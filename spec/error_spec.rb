# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket::Error do
  # Recursively collects every leaf error class nested under `mod` (i.e. every
  # class that defines its own #message, as opposed to abstract intermediate
  # classes like WebSocket::Error::Frame or WebSocket::Error::Handshake).
  def self.leaf_error_classes(mod)
    mod.constants(false).each_with_object([]) do |const_name, list|
      const = mod.const_get(const_name)
      next unless const.is_a?(Class) && const < described_class

      list << const if const.instance_methods(false).include?(:message)
      list.concat(leaf_error_classes(const))
    end
  end

  it 'is a RuntimeError' do
    expect(described_class).to be < RuntimeError
  end

  errors = leaf_error_classes(described_class)

  it 'found at least one leaf error class to verify' do
    expect(errors).not_to be_empty
  end

  errors.each do |klass|
    describe klass do
      subject(:error) { klass.new }

      it 'exposes a symbolic message describing the failure' do
        expect(error.message).to be_a(Symbol)
      end
    end
  end
end
