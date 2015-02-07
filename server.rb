require 'socket'

DEFAULT_PORT = 8005

server = TCPServer.new(DEFAULT_PORT)


 ip = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
port = server.addr[1].to_s


puts "Ready to receive on "+ ip +":" + port

@numOfClients = 0



while (connection = server.accept)
  Thread.new(connection) do |conn|
    port, host = conn.peeraddr[1,2]
    client = "#{host}:#{port}"
    puts "#{client} is connected"
    @numOfClients = @numOfClients + 1
    puts "Clients currently connected: #{@numOfClients}"
    begin
      loop do
        message = conn.readline
        puts "#{client} says: #{message}"
        conn.puts(message)
      end
    rescue EOFError
      conn.close
      @numOfClients = @numOfClients - 1
    
      puts "#{client} has disconnected"
        puts "Clients currently connected: #{@numOfClients}"
    end
  end
end