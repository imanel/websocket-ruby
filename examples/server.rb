module EventMachine
  module WebSocket
    class Connection < EventMachine::Connection

      ###########
      ### API ###
      ###########

      def onopen(&blk);     @onopen = blk;    end # Called when connection is opened
      def onclose(&blk);    @onclose = blk;   end # Called when connection is closed
      def onerror(&blk);    @onerror = blk;   end # Called when error occurs
      def onmessage(&blk);  @onmessage = blk; end # Called when message is received from client
      def onping(&blk);     @onping = blk;    end # Called when ping message is received from client
      def onpong(&blk);     @onpong = blk;    end # Called when pond message is received from client

      # Send data to client
      # Return true if data was send, otherwise call on_error if needed.
      def send(data, options = {})
        type = options[:type] || :text
        unless type == :plain
          frame = WebSocket::Frame::Outgoing.new(:version => @handshake.version, :data => data, :type => type)
          if !frame.supported?
            trigger_onerror("Frame type '#{type}' is not supported in protocol version #{@handshake.version}")
            return false
          elsif !frame.require_sending?
            return false
          end
          data = frame.to_binary
        end
        send_data(data)
        true
      end

      # Close connection
      # Return true if connection is closed immediately
      def close
        return false if @state == :open && send('', :type => :close)
        @state = :closed
        close_connection
        true
      end

      # Send ping message to client
      # Return false if protocol version is not supporting ping requests
      def ping(data = '')
        send(data, :type => :ping)
      end

      # Send pong message to client
      # Return false if protocol version is not supporting pong requests.
      def pong(data = '')
        send(data, :type => :pong)
      end

      ############################
      ### Eventmachine methods ###
      ############################

      def initialize(options)
        @options = options
        @secure = options[:secure] || false
        @tls_options = options[:tls_options] || {}

        @state = :connecting
        @handshake = WebSocket::Handshake::Server.new
      end

      def post_init
        start_tls(@tls_options) if @secure
      end

      def receive_data(data)
        case @state
        when :connecting then handle_connecting(data)
        when :open then handle_open(data)
        when :closing then handle_closing(data)
        end
      end

      def unbind
        unless @state == :closed
          @state = :closed
          close
          trigger_onclose
        end
      end

      #######################
      ### Private methods ###
      #######################

      private

      ['onopen', 'onclose'].each do |m|
        define_method "trigger_#{m}" do
          callback = instance_variable_get("@#{m}")
          callback.call if callback
        end
      end

      ['onerror', 'onmessage', 'onping', 'onpong'].each do |m|
        define_method "trigger_#{m}" do |data|
          callback = instance_variable_get("@#{m}")
          callback.call(data) if callback
        end
      end

      def handle_connecting(data)
        @handshake << data
        return unless @handshake.finished?
        if @handshake.valid?
          send(@handshake.response.to_s, :type => :plain)
          @frame = WebSocket::Frame::Incoming.new(:version => @handshake.version)
          @state = :open
          trigger_onopen
        else
          trigger_onerror(@handshake.error)
          close
        end
      end

      def handle_open(data)
        @frame << data
        while frame = @frame.next
          case frame.type
          when :close
            @state = :closing
            close
            trigger_onclose
          when :ping
            pong(frame.to_s)
            trigger_onping(frame.to_s)
          when :pong
            trigger_onpong(frame.to_s)
          when :text
            trigger_onmessage(frame.to_s)
          when :binary
            trigger_onmessage(frame.to_binary)
          end
        end
      end

      def handle_closing(data)
        @state = :closed
        close
        trigger_onclose
      end

    end
  end
end
