module LibWebSocket
  # Base class for all classes with states
  module Stateful

    attr_accessor :state

    # Return true if current state match given state
    def state?(val)
      @state == val
    end

    # Change state to 'done'
    def done
      @state = 'done'
      true
    end

    # Check if current state is done
    def done?
      @state == 'done'
    end

  end
end
