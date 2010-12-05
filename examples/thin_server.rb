#!/usr/bin/env ruby

require 'rubygems'
require 'thin'
require File.expand_path(File.dirname(__FILE__) + '/../lib/libwebsocket')

# This is required due to thin incompatibility with streamming of data
module ThinExtension
  def self.included(thin_conn)
     thin_conn.class_eval do
       alias :pre_process_without_websocket :pre_process
       alias :pre_process :pre_process_with_websocket

       alias :receive_data_without_websocket :receive_data
       alias :receive_data :receive_data_with_websocket
     end
   end

   attr_accessor :websocket_client

   def pre_process_with_websocket
     @request.env['async.connection'] = self
     pre_process_without_websocket
   end
   def receive_data_with_websocket(data)
     if self.websocket_client
       self.websocket_client.receive_data(data)
     else
       receive_data_without_websocket(data)
     end
   end
end

::Thin::Connection.send(:include, ThinExtension)

class EchoServer
  def call(env)
    @hs ||= LibWebSocket::OpeningHandshake::Server.new
    @connection = env['async.connection']

    if !@hs.done?
      @hs.parse(env)

      if @hs.done?
        @connection.websocket_client = self
        resp = @hs.to_rack
        return resp
      end

      return
    end
  end

  def receive_data(data)
    @frame ||= LibWebSocket::Frame.new

    @frame.append(data)

    while message = @frame.next
      @connection.send_data @frame.new(message).to_s
    end
  end
end

Thin::Server.start('127.0.0.1', 8080) do
  map '/' do
    run proc{ |env| EchoServer.new.call(env) }
  end
end