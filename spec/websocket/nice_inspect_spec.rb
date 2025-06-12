# frozen_string_literal: true

require 'spec_helper'

# Dummy class to test the NiceInspect module
class InspectableClass
  include WebSocket::NiceInspect

  def initialize(val1, val2)
    @my_string = val1
    @my_number = val2
    @my_array = [1, 'two', :three]
  end
end

# Another dummy class with no instance variables
class EmptyInspectableClass
  include WebSocket::NiceInspect
end

RSpec.describe WebSocket::NiceInspect do
  describe '#inspect' do
    context 'with a class having instance variables' do
      let(:instance) { InspectableClass.new("hello", 123) }
      let(:inspection) { instance.inspect }

      it 'returns a string starting with the class name and object ID (lines 7, 8, 9)' do
        # Matches <InspectableClass:0x SometHexID ... >
        expect(inspection).to match(/^<InspectableClass:0x[0-9a-f]+ .*?>$/)
      end

      it 'includes instance variable names and their inspected values (line 7)' do
        expect(inspection).to include('@my_string="hello"')
        expect(inspection).to include('@my_number=123')
        expect(inspection).to include('@my_array=[1, "two", :three]')
      end

      it 'formats the output correctly with class name, object id, and variables (line 9)' do
        # Example: <InspectableClass:0x00000000 @my_string="hello", @my_number=123, @my_array=[1, "two", :three]>
        expected_regex_str = Regexp.escape('<InspectableClass:0x') +
                             '[0-9a-f]+' + # Object ID hex
                             Regexp.escape(' @my_string="hello", @my_number=123, @my_array=[1, "two", :three]>')
        expect(inspection).to match(Regexp.new(expected_regex_str))
      end
    end

    context 'with a class having no instance variables' do
      let(:empty_instance) { EmptyInspectableClass.new }
      let(:empty_inspection) { empty_instance.inspect }

      it 'returns a string with class name, object ID, and no variables shown (lines 7, 8, 9)' do
        # Example: <EmptyInspectableClass:0x00000000 > (note the space before >)
        expected_regex_str = Regexp.escape('<EmptyInspectableClass:0x') +
                             '[0-9a-f]+' +
                             Regexp.escape(' >') # Space indicates empty vars string
        expect(empty_inspection).to match(Regexp.new(expected_regex_str))
      end
    end
  end
end
