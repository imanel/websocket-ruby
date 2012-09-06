require "#{File.expand_path(File.dirname(__FILE__))}/../server"

EM.epoll
EM.run do

  trap("TERM") { stop }
  trap("INT")  { stop }

  WebSocket::EventMachine::Server.start(:host => "0.0.0.0", :port => 8080) do |ws|

    ws.onopen do
      puts "Client connected"
    end

    ws.onmessage do |msg|
      puts "Received message #{msg}"
      puts.send "Pong: #{msg}"
    end

    ws.onclose do
      puts "Client disconnected"
    end

    ws.onerror do |e|
      puts "Error: #{e}"
    end

  end

end
