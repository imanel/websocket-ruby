require "#{File.expand_path(File.dirname(__FILE__))}/../client"
require 'cgi'

EM.epoll
EM.run do

  host   = 'ws://localhost:9001'
  agent  = "WebSocket-Ruby (Ruby #{RUBY_VERSION})"
  cases  = 0
  skip   = []

  ws = WebSocket::EventMachine::Client.connect(:uri => "#{host}/getCaseCount")

  ws.onmessage do |msg, type|
    puts "$ Total cases to run: #{msg}"
    cases = msg.to_i
  end

  ws.onclose do

    run_case = lambda do |n|

      if n > cases
        puts "$ Requesting report"
        ws = WebSocket::EventMachine::Client.connect(:uri => "#{host}/updateReports?agent=#{CGI.escape agent}")
        ws.onclose do
          EM.stop
        end

      elsif skip.include?(n)
        EM.next_tick { run_case.call(n+1) }

      else
        puts "$ Test number #{n}"
        ws = WebSocket::EventMachine::Client.connect(:uri => "#{host}/runCase?case=#{n}&agent=#{CGI.escape agent}")

        ws.onmessage do |msg, type|
          puts "Received #{msg}(#{type})"
          ws.send(msg, :type => type)
        end

        ws.onclose do |msg|
          puts("Closing: #{msg}") if msg
          run_case.call(n + 1)
        end
      end
    end

    run_case.call(1)
  end

end
