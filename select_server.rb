require 'socket'
require 'logger'

#---Variables
DEFAULT_PORT = 8005
HOST = Socket::getaddrinfo(Socket.gethostname, "echo", Socket::AF_INET)[0][3]
fileDescriptors = []
lock = Mutex.new
log = Logger.new( 'select_log.txt' )

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

#---Prints exception to STDOUT
def print_exception(e)
	puts "error: #{e.message}"
end

fileDescriptors.push( server )

#---Main
begin
	puts "Server started on: #{HOST}:#{DEFAULT_PORT}"

	while 1
		connection = IO.select(fileDescriptors)

		if connection != nil then

			for sock in connection[0]

				if sock == server then
					newSock = server.accept()
					fileDescriptors.push( newSock )
					puts fileDescriptors.length - 1

				else
					if sock.eof?
						closeConnection( sock, fileDescriptors)
					else
						str = sock.gets
						sock.puts( str )
						puts str
					end
				end
			end
		end
	end
rescue SystemExit, Interrupt #--catches Ctrl-c
	system( "clear" )
	puts "User shutdown detected."
rescue Exception => e
	print_exception(e)
end


