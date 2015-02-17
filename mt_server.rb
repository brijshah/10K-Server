require 'socket'
require 'logger'

#---Variables
DEFAULT_PORT = 8005
HOST = Socket::getaddrinfo(Socket.gethostname, "echo", Socket::AF_INET)[0][3]
clientConnections = []
lock = Mutex.new
@totalConnected = 0
log = Logger.new( 'mt_log.txt' )

#---Create Server
server = TCPServer.new( DEFAULT_PORT )
server.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )

#---Generates client name and prints
def clientHandler(client)
	port, host = client.peeraddr[1,2]
	clientname = "#{host}:#{port}"
	puts "#{clientname} connected"
end

#---Prints amount of connections and closes socket
def closeConnection( clientSock, clientConnections)
	puts clientConnections.length
	clientSock.close
	clientConnections.delete(clientSock)
end

#-- Prints exception to STDOUT
def print_exception(e)
	puts "error: #{e.message}"
end

#---Main
begin
	puts "Server started on: #{HOST}:#{DEFAULT_PORT}"
	while 1
		Thread.fork(server.accept) do |client|
			clientHandler(client)
			clientConnections.push(client)
			@totalConnected += 1
			#puts "Clients connected: #{clientConnections.length}"
			loop do
				data = client.readline
				puts "[#{@totalConnected}], Received: #{data}"
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
rescue SystemExit, Interrupt #---Catches Ctrl-C
	system( "clear" )
	puts "Maximum Connections: #{@totalConnected}"
	puts "User shutdown detected."
rescue Exception => e
	print_exception(e)
end


