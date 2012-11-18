require "#{File.expand_path(File.dirname(__FILE__))}/../client"

EM.epoll
EM.run do

  trap("TERM") { stop }
  trap("INT")  { stop }

  ws = WebSocket::EventMachine::Client.connect(:host => "localhost", :port => 9001, :version => 13);

  ws.onopen do
    puts "Client connected"
    ws.send "Hello"
  end

  ws.onmessage do |msg, type|
    puts "Received message: #{msg}"
    ws.send msg, :type => type
  end

  ws.onclose do
    puts "Client disconnected"
  end

  ws.onerror do |e|
    puts "Error: #{e}"
  end

  ws.onping do |msg|
    puts "Receied ping: #{msg}"
  end

  ws.onpong do |msg|
    puts "Received pong: #{msg}"
  end

  puts "Server started at port 9001"

  def stop
    puts "Terminating WebSocket Server"
    EventMachine.stop
  end

end
