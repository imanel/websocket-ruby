# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WebSocket do
  describe '.max_frame_size' do
    around do |example|
      original = described_class.max_frame_size
      example.run
      described_class.max_frame_size = original
    end

    it 'defaults to 20MB' do
      described_class.instance_variable_set(:@max_frame_size, nil)
      expect(described_class.max_frame_size).to eql(20 * 1024 * 1024)
    end

    it 'can be reconfigured' do
      described_class.max_frame_size = 1024
      expect(described_class.max_frame_size).to be(1024)
    end
  end

  describe '.should_raise' do
    around do |example|
      original = described_class.should_raise
      example.run
      described_class.should_raise = original
    end

    it 'defaults to false' do
      described_class.instance_variable_set(:@should_raise, nil)
      expect(described_class.should_raise).to be false
    end

    it 'can be reconfigured' do
      described_class.should_raise = true
      expect(described_class.should_raise).to be true
    end
  end

  describe '.load_native_extension' do
    it 'silently ignores a missing websocket-native gem' do
      allow(described_class).to receive(:require)
        .with('websocket-native')
        .and_raise(LoadError, 'cannot load such file -- websocket-native')

      expect { described_class.load_native_extension }.not_to raise_error
    end

    it 're-raises load errors unrelated to websocket-native' do
      allow(described_class).to receive(:require)
        .with('websocket-native')
        .and_raise(LoadError, 'cannot load such file -- some_other_gem')

      expect { described_class.load_native_extension }.to raise_error(LoadError, /some_other_gem/)
    end
  end
end
