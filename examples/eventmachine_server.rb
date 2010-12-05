#!/usr/bin/env ruby

require 'rubygems'
require 'eventmachine'
require File.expand_path(File.dirname(__FILE__) + '/../lib/libwebsocket')

module EchoServer
  def receive_data(data)
    @hs ||= LibWebSocket::OpeningHandshake::Server.new
    @frame ||= LibWebSocket::Frame.new

    if !@hs.done?
      @hs.parse(data)

      if @hs.done?
        send_data(@hs.to_s)
      end

      return
    end

    @frame.append(data)

    while message = @frame.next
      send_data @frame.new(message).to_s
    end
  end

end

EventMachine::run do
  host = '0.0.0.0'
  port = 8080
  EventMachine::start_server host, port, EchoServer
  puts "Started EchoServer on #{host}:#{port}..."
end