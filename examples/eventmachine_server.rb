module EventMachine
  module WebSocket
    class Connection < EventMachine::Connection

      ###########
      ### API ###
      ###########

      def on_open(&blk);     @on_open = blk;    end # Called when connection is opened
      def on_close(&blk);    @on_close = blk;   end # Called when connection is closed
      def on_error(&blk);    @on_error = blk;   end # Called when error occurs
      def on_message(&blk);  @on_message = blk; end # Called when message is received from client
      def on_ping(&blk);     @on_ping = blk;    end # Called when ping message is received from client
      def on_pong(&blk);     @on_pong = blk;    end # Called when pond message is received from client

      # Close connection
      def close
      end

      # Send data to client
      def send(data)
      end

      # Send ping message to client
      def ping(data = '')
      end

      # Send pong message to client
      def pong(data = '')
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
        when :closed then handle_closed(data)
        end
      end

      def unbind
      end

      #######################
      ### Private methods ###
      #######################

      private

      ['on_open', 'on_close'].each do |m|
        define_method "trigger_#{m}" do
          callback = instance_variable_get("@#{m}")
          callback.call if callback
        end
      end

      ['on_error', 'on_message', 'on_ping', 'on_pong'].each do |m|
        define_method "trigger_#{m}" do |data|
          callback = instance_variable_get("@#{m}")
          callback.call(data) if callback
        end
      end

      def handle_connecting(data)
        @handshake << data
        return unless @handshake.finished?
        if @handshake.valid?
          send(@handshake.response.to_s)
          @frame = WebSocket::Frame::Incoming.new(:version => @handshake.version)
          @state = :open
          trigger_on_open
        else
          trigger_on_error(@handshake.error)
          close_connection
        end
      end

      def handle_open(data)
        @frame << data
        while frame = @frame.next
          case frame.type
          when :close
            close
            trigger_on_close
          when :ping
            pong(frame.to_s)
            trigger_on_ping(frame.to_s)
          when :pong
            trigger_on_pong(frame.to_s)
          when :text
            trigger_on_message(frame.to_s)
          when :binary
            trigger_on_message(frame.to_binary)
          end
        end
      end

      def handle_closing(data)
      end

      def handle_closed(data)
      end

    end
  end
end
