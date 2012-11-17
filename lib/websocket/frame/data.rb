module WebSocket
  module Frame
    class Data < String

      # Required for support of Ruby 1.8
      unless new.respond_to?(:getbyte)
        def getbyte(i)
          self[i]
        end
      end

    end
  end
end
