#!/usr/bin/env ruby

#-----------------------------------------------------------------------------
#-- SOURCE FILE:    select_server.rb
#--
#-- PROGRAM:        IO.Select Echo Server
#--
#-- FUNCTIONS:      
#--                 def clientHandler(client)
#--					def closeConnection(clientSock, clientConnections)
#--					def print_exception(e)
#--
#-- DATE:           February 17, 2015
#--
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- This server accepts incoming TCP connections from clients. It reads data
#-- from the socket and echoes it back to the client. This application is 
#-- implemented with an IO.Select blocking accept call. All statistics are logged
#-- using Ruby's logger.
#--
#-- This server is best suited to be used with the supplied client:
#-- client.rb
#----------------------------------------------------------------------------*/

require 'socket'
require 'logger'

#---Variables
DEFAULT_PORT = 8005
HOST = Socket::getaddrinfo(Socket.gethostname, "echo", Socket::AF_INET)[0][3]
fileDescriptors = []
lock = Mutex.new
$buffer_size = 20
@totalConnected = 0
$receivedData = 0
$sentData = 0

#--- Create Log File & set appropriate formatting
$log = Logger.new( 'select_log.txt' )

$log.formatter = proc do |severity, datetime, progname, msg|
	"[#{datetime.strftime('%Y-%m-%d %H:%M:%S:%L')}]: #{msg}\n"
end


#---Create TCP Server
server = TCPServer.new( DEFAULT_PORT )
server.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )

#-----------------------------------------------------------------------------
#-- FUNCTION:       def clientHandler(client)   
#--
#-- DATE:           January 17, 2015
#--
#-- VARIABLES(S):   client is an a socket connection to the server
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- This function generates a client connection with the appropriate
#-- port and host number and prints it to STDOUT.
#----------------------------------------------------------------------------*/
def clientHandler(client)
	port, host = client.peeraddr[1,2]
	$clientname = "#{host}:#{port}"
	puts "#{$clientname} is connected"
end

#-----------------------------------------------------------------------------
#-- FUNCTION:       def closeConnection(clientSock, clientConnections)   
#--
#-- DATE:           January 17, 2015
#--
#-- VARIABLES(S):   clientSock is
#--					client Connections is
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- This function prints the amount of connections to the server to STDOUT
#-- and proceeds to close the socket connection and delete the main 
#-- connection from the list of current connections.
#----------------------------------------------------------------------------*/
def closeConnection( clientSock, clientConnections)
	#puts clientConnections.length
	clientSock.close
	clientConnections.delete(clientSock)
end

#-----------------------------------------------------------------------------
#-- FUNCTION:       def print_exception(e)    
#--
#-- DATE:           January 17, 2015
#--
#-- VARIABLES(S):   e is an exception
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- This function prints out an exception's error to STDOUT.
#----------------------------------------------------------------------------*/
def print_exception(e)
	puts "error: #{e.message}"
end

def sysExit
	system( "clear" )
	puts "Maximum Connected: #{@totalConnected}"
	puts "Logging Statistics...."
	$log.info "Select Server Stopped"
	$log.info "Maximum Connections: #{$totalConnected}"
	$log.info "Total bytes transferred in: #{$receivedData} B"
	$log.info "Total bytes transferred out: #{$sentData} B"
	$log.info "Total bytes transferred: #{$receivedData + $sentData} B"
end

#---Main
STDOUT.sync = true

fileDescriptors.push( server )

if ARGV.empty? || ARGV.count > 1
	puts "Usage: ruby select_server.rb [buffer_size]"
	exit
elsif ARGV.count == 1
	$buffer_size = ARGV[0].to_i
end

begin
	puts "Server started on: #{HOST}:#{DEFAULT_PORT}"
	$log.info "Select Sever started"

	while 1
		connection = IO.select(fileDescriptors)

		if connection != nil then

			for sock in connection[0]

				if sock == server then
					newSock = server.accept()
					#clientHandler(newSock)
					#$log.info "#{$clientname} connected"
					fileDescriptors.push( newSock )
					@totalConnected += 1
					#puts fileDescriptors.length - 1

				else
					if sock.eof?
						closeConnection( sock, fileDescriptors)
					else
						str = sock.read( $buffer_size )
						#$log.info "#{$clientname}_IN : #{str.bytesize}"
						$receivedData += str.bytesize
						sock.write( str )
						#$log.info "#{$clientname}_OUT : #{str.bytesize}\n"
						$sentData += str.bytesize
						sock.flush
						#puts "[#{@totalConnected}], Received: #{str}"
					end
				end
			end
		end
	end
rescue SystemExit, Interrupt #--catches Ctrl-c
	system("clear")
	puts "Maximum Connected: #{@totalConnected}"
	puts "User shutdown detected."
rescue Exception => e
	print_exception(e)
ensure
	sysExit
end


