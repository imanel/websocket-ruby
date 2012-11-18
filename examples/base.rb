require 'rubygems'
require 'eventmachine'
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/websocket"

module WebSocket
  module EventMachine
    class Base < ::EventMachine::Connection

      ###########
      ### API ###
      ###########

      def onopen(&blk);     @onopen = blk;    end # Called when connection is opened
      def onclose(&blk);    @onclose = blk;   end # Called when connection is closed
      def onerror(&blk);    @onerror = blk;   end # Called when error occurs
      def onmessage(&blk);  @onmessage = blk; end # Called when message is received from server
      def onping(&blk);     @onping = blk;    end # Called when ping message is received from server
      def onpong(&blk);     @onpong = blk;    end # Called when pond message is received from server

      # Send data to client
      # @param data [String] Data to send
      # @param args [Hash] Arguments for send
      # @option args [String] :type Type of frame to send - available types are "text", "binary", "ping", "pong" and "close"
      # @return [Boolean] true if data was send, otherwise call on_error if needed
      def send(data, args = {})
        type = args[:type] || :text
        unless type == :plain
          frame = outgoing_frame.new(:version => @handshake.version, :data => data, :type => type)
          if !frame.supported?
            trigger_onerror("Frame type '#{type}' is not supported in protocol version #{@handshake.version}")
            return false
          elsif !frame.require_sending?
            return false
          end
          data = frame.to_s
        end
        # debug "Sending raw: ", data
        send_data(data)
        true
      end

      # Close connection
      # @return [Boolean] true if connection is closed immediately, false if waiting for server to close connection
      def close
        if @state == :open
          @state = :closing
          return false if send('', :type => :close)
        else
          send('', :type => :close) if @state == :closing
          @state = :closed
        end
        close_connection_after_writing
        true
      end

      # Send ping message to client
      # @return [Boolean] false if protocol version is not supporting ping requests
      def ping(data = '')
        send(data, :type => :ping)
      end

      # Send pong message to client
      # @return [Boolean] false if protocol version is not supporting pong requests
      def pong(data = '')
        send(data, :type => :pong)
      end

      ############################
      ### EventMachine methods ###
      ############################

      def receive_data(data)
        # debug "Received raw: ", data
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
          trigger_onclose('')
        end
      end

      #######################
      ### Private methods ###
      #######################

      private

      ['onopen'].each do |m|
        define_method "trigger_#{m}" do
          callback = instance_variable_get("@#{m}")
          callback.call if callback
        end
      end

      ['onerror', 'onping', 'onpong', 'onclose'].each do |m|
        define_method "trigger_#{m}" do |data|
          callback = instance_variable_get("@#{m}")
          callback.call(data) if callback
        end
      end

      def trigger_onmessage(data, type)
        @onmessage.call(data, type) if @onmessage
      end

      def handle_connecting(data)
        @handshake << data
        return unless @handshake.finished?
        if @handshake.valid?
          send(@handshake.to_s, :type => :plain) if @handshake.should_respond?
          @frame = incoming_frame.new(:version => @handshake.version)
          @state = :open
          trigger_onopen
          handle_open(@handshake.leftovers) if @handshake.leftovers
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
            trigger_onclose(frame.to_s)
          when :ping
            pong(frame.to_s)
            trigger_onping(frame.to_s)
          when :pong
            trigger_onpong(frame.to_s)
          when :text
            trigger_onmessage(frame.to_s, :text)
          when :binary
            trigger_onmessage(frame.to_s, :binary)
          end
        end
        unbind if @frame.error?
      end

      def handle_closing(data)
        @state = :closed
        close
        trigger_onclose
      end

      def debug(description, data)
        puts(description + data.bytes.to_a.collect{|b| '\x' + b.to_s(16).rjust(2, '0')}.join) unless @state == :connecting
      end

    end
  end
end
