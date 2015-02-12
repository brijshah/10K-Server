require 'socket'

DEFAULT_PORT = 8005

server = TCPServer.new(DEFAULT_PORT)


SRV_IP = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
port = server.addr[1].to_s
@numOfClients = 0


def checkConnected
  var = Thread.new{
    while(true)
      sleep 5
      puts "Clients currently connected: #{@numOfClients}"
    end
  }
end

puts "Server started: #{SRV_IP}:#{port}"

checkConnected

while (connection = server.accept)
  Thread.new(connection) do |conn|
    port, host = conn.peeraddr[1,2]
    client = "#{host}:#{port}"
    puts "#{client} is connected"
    @numOfClients = @numOfClients + 1
    begin
      loop do
        message = conn.readline
        puts "#{client} says: #{message}"
        sleep(0.9)
        conn.puts(message)
      end
    rescue EOFError
      conn.close
      @numOfClients = @numOfClients - 1
    
      puts "#{client} has disconnected"
    end
  end
end