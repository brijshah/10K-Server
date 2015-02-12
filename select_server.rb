require 'socket'

DEFAULT_PORT = 8005

@server = TCPServer.new(DEFAULT_PORT)

SRV_IP = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
port = @server.addr[1].to_s

@numOfClients = 0
@reading = Array.new

def checkConnected
  var = Thread.new{
    while(true)
      sleep 13
      puts "Clients currently connected: #{@numOfClients}"
    end
  }
end

puts "Server started: #{SRV_IP}:#{port}"

checkConnected

@reading.push(@server)

while 1
	connection = select(@reading.push)
	if connection != nil then

		for sock in connection[0]

			if sock == @server then
				newSock = @server.accept()
				@reading.push (newSock)
				@numOfClients = (@reading.length) -1
				puts "Clients connected: #{@numOfClients}"
			else
				if sock.eof?
					sock.close
					@reading.delete(sock)
					@numOfClients = @reading.length
					puts "Clients connected: #{@numOfClients}"
					
				else
					str = sock.gets
					sock.puts(str)
					puts str
				end
			end
		end
	end
end




