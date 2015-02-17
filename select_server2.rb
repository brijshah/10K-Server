#!/usr/bin/env ruby

require 'socket'
require 'logger'

#---Variables
DEFAULT_PORT = 8005
@reading = []
@writing = []
@lock = Mutex.new
$totalConnected = 0

#---Create log file
$log = Logger.new( 'select_log.txt' )

#---Create Server
@server = TCPServer.new( DEFAULT_PORT )
@server.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )

#---Generates client name and prints
def clientHandler(client)
	port, host = client.peeraddr[1,2]
	clientname = "#{host}:#{port}"
	puts "#{clientname} is connected"
end

#---Prints amount of connections and closes socket
def closeConnection( clientSock, clientConnections)
	#puts clientConnections.length
	clientSock.close
	clientConnections.delete(clientSock)
end

#---Prints exception to STDOUT
def print_exception(e)
	puts "error: #{e.message}"
end

#---Main
STDOUT.sync = true

@reading.push (@server)
begin
	puts "Select Server Start on port: #{DEFAULT_PORT}"
	while 1

		begin
			@lock.synchronize{
				@readable, writable = IO.select(@reading, @writing)
			}
		rescue IOError
			#wut?
		end

		@readable.each do |socket|
			if socket == @server
				begin
					Thread.start(@server.accept_nonblock) do |client|
						@lock.synchronize{
							@reading.push(client)
						}
						clientHandler(client)
						$totalConnected += 1

						begin
							loop do
								line = client.readline
								client.puts(line)
							end
						rescue EOFError
							client.close
							@lock.synchronize{
								@reading.delete(client)
							}
						rescue Exception => e
							print_exception(e)
						end
					end
				rescue Exception => e
					print_exception(e)
				end
			end
		end
	end
rescue SystemExit, Interrupt
	system( "clear")
	puts "User shutdown detected."
	puts "Maximum Clients: #{$totalConnected}"
rescue Exception => e
	print_exception(e)
end
