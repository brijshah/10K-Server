require 'socket'

#---Variables
DEFAULT_PORT = 8005
HOST = 'localhost'
clientConnections = []
lock = Mutex.new

#---Create Server
server = TCPServer.new( DEFAULT_PORT )
server.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )

#---Generates client name and prints
def clientHandler(client)
	port, host = client.peeraddr[1,2]
	clientname = "#{host}:#{port}"
	puts "#{clientname} is connected"
end

#---Prints amount of connections and closes socket
def closeConnection( clientSock, clientConnections)
	puts clientConnections.length
	clientSock.close
	clientConnections.delete(clientSock)
end

#---Main
begin
	puts "Server started on Port: #{DEFAULT_PORT}"
	while 1
		Thread.fork(server.accept) do |client|
			clientHandler(client)
			clientConnections.push(client)
			puts "Clients connected: #{clientConnections.length}"
			loop do
				data = client.readline
				puts "#{data}"
				client.puts(data.chomp)

				if client.eof?
					lock.synchronize do
						closeConnection( client, clientConnections)
					end
					break
				end
			end
		end
	end
rescue SystemExit, Interrupt
	system( "clear" )
	puts "User shutdown detected."
rescue Exception => e
	puts "Exception: #{e.message}"
end


