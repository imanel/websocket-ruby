module WebSocket
  module Common

    attr_reader :error, :version

    def self.included(base)
      base.extend(ClassMethods)
    end

    # Recreate inspect as #to_s was overwritten
    def inspect
      vars = self.instance_variables.map { |v| "#{v}=#{instance_variable_get(v).inspect}" }.join(', ')
      insp = "#{self.class}:0x%08x" % (self.__id__ * 2)
      "<#{insp} #{vars}>"
    end

    private

    # Include set of methods for selected protocol version
    def include_version(type, subtype)
      self.class.const_get('VERSION_MAP').each do |versions, target|
        next unless versions.include?(@version)
        handler_class = WebSocket.const_get [type.to_s, 'Handler', subtype.to_s + target].join('::')
        return @handler = handler_class.new(self)
      end

      raise WebSocket.const_get("Error::#{type}::UnknownVersion")
    end

    # Changes state to error and sets error message
    # @param [String] message Error message to set
    def set_error(message)
      @error = message
    end

    module ClassMethods

      # Rescue from WebSocket::Error errors.
      #
      # @param [String] method_name Name of method that should be wrapped and rescued
      # @param [Hash] options Options for rescue
      #
      # @options options [Any] :return Value that should be returned instead of raised error
      def rescue_method(method_name, options = {})
        define_method "#{method_name}_with_rescue" do |*args|
          begin
            send("#{method_name}_without_rescue", *args)
          rescue WebSocket::Error => e
            set_error(e.message.to_sym)
            WebSocket.should_raise ? raise : options[:return]
          end
        end
        alias_method "#{method_name}_without_rescue", method_name
        alias_method method_name, "#{method_name}_with_rescue"
      end

    end

  end
end
