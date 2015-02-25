#!/usr/bin/env ruby

#-----------------------------------------------------------------------------
#-- SOURCE FILE:    mt_server.rb
#--
#-- PROGRAM:        Multi-Threaded Echo Server
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
#-- multi-threaded with a blocking accept call. All statistics are logged
#-- using Ruby's logger. All Data should be thread-safe with the 
#-- implementation of mutexes.
#--
#-- This server is best suited to be used with the supplied client:
#-- client.rb
#----------------------------------------------------------------------------*/

require 'socket'
require 'logger'
require 'thread'

#---Variables
DEFAULT_PORT = 8005
clientConnections = []
lock = Mutex.new
$totalConnected = 0
$buffer_size = 20
$receivedData = 0
$sentData = 0

#--Create log file & set appropriate formatting
$log = Logger.new( "mt_log.txt" )

$log.formatter = proc do |severity, datetime, progname, msg|
	"[#{datetime.strftime('%Y-%m-%d %H:%M:%S:%L')}]: #{msg}\n"
end

#---Create Server
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
	puts "#{$clientname} connected"
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
	puts "Maximum Connections: #{$totalConnected}"
	puts "Logging Statistics...."
	$log.info "Multi-Threaded Server Stopped"
	$log.info "Maximum Connections: #{$totalConnected}"
	$log.info "Total bytes transferred in: #{$receivedData} B"
	$log.info "Total bytes transferred out: #{$sentData} B"
	$log.info "Total bytes transferred: #{$receivedData + $sentData} B"
end

#---Main
STDOUT.sync = true

if ARGV.empty? || ARGV.count > 1
	puts "Usage: ruby mt_server.rb [buffer_size]"
	exit
elsif ARGV.count == 1
	$buffer_size = ARGV[0].to_i
end

begin
	puts "Multi-Threaded Server started port on: #{DEFAULT_PORT}"
	$log.info "Multi-Threaded Server started"
	while 1
		Thread.fork(server.accept) do |client|
			#clientHandler(client)
			#$log.info "#{$clientname} connected"
			clientConnections.push(client)
			$totalConnected += 1
			#puts "Clients connected: #{clientConnections.length}"
			loop do
				data = client.read($buffer_size)
				#$log.info "#{$clientname}_IN: #{data.bytesize}"
				$receivedData += data.bytesize

				#puts "[#{@totalConnected}], Received: #{data}"

				client.write(data)
				#$log.info "#{$clientname}_OUT: #{data.bytesize}\n"
				$sentData += data.bytesize

				client.flush

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
	puts "Maximum Connections: #{$totalConnected}"
	puts "User shutdown detected."
rescue Exception => e
	print_exception(e)
ensure
	sysExit
end


