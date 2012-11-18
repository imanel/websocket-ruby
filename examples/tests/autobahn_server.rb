require "#{File.expand_path(File.dirname(__FILE__))}/../server"

EM.epoll
EM.run do

  trap("TERM") { stop }
  trap("INT")  { stop }

  WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => 9001) do |ws|

    ws.onmessage do |msg, type|
      ws.send msg, :type => type
    end

  end

  puts "Server started at port 9001"

  def stop
    puts "Terminating WebSocket Server"
    EventMachine.stop
  end

end
