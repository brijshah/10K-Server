#!/usr/bin/env ruby

#-----------------------------------------------------------------------------
#-- SOURCE FILE:    epoll_server.rb
#--
#-- PROGRAM:        Epoll Echo Server
#--
#-- FUNCTIONS:      
#--                 def clientHandler()
#--					def print_exception(e)
#--
#-- DATE:           February 19, 2015
#--
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- This server accepts incoming TCP connections from clients. It reads data
#-- from the socket and echoes it back to the client. This application is 
#-- implemented with an event driven blocking accept call. All statistics are logged
#-- using Ruby's logger.
#--
#-- This server is best suited to be used with the supplied client:
#-- client.rb
#----------------------------------------------------------------------------*/

require 'socket'
require 'rubygems'
require 'eventmachine'
require 'logger'

#---Variables
DEFAULT_PORT = 8005
$totalConnections = 0
$receivedData = 0
$sentData = 0
$totalData = $receivedData + $sentData

#--Creating log file & set appropriate formatting
$log = Logger.new('epoll_log.txt')

$log.formatter = proc do |severity, datetime, progname, msg|
	"[#{datetime.strftime('%Y-%m-%d %H:%M:%S:%L')}]: #{msg}\n"
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
	puts "#{e.message}"
end

#-----------------------------------------------------------------------------
#-- FUNCTION:       def clientHandler()   
#--
#-- DATE:           January 17, 2015
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- This function generates a client connection with the appropriate
#-- port and host number and prints it to STDOUT.
#----------------------------------------------------------------------------*/
def clientHandler()
	port, ip = Socket.unpack_sockaddr_in(get_peername)
	$clientName = "#{ip}:#{port}"
	puts "#{$clientName} connected"
end

def sysExit
		system( "clear" )
	puts "Maximum Connections: #{$totalConnections}"
	puts "Logging Statistics...."
	$log.info "Epoll Server Stopped"
	$log.info "Maximum Connections: #{$totalConnections}"
	$log.info "Total bytes transferred in: #{$receivedData} B"
	$log.info "Total bytes transferred out: #{$sentData} B"
	$log.info "Total bytes transferred: #{$receivedData + $sentData} B"
end

#---Module used with eventmachine.
module EchoServer
	$clients = 0

	def post_init
		#clientHandler
		#$log.info "#{$clientName} connected"
		$clients += 1
		$totalConnections += 1
	end

	def receive_data data
		#$log.info "#{$clientName}_IN : #{data.bytesize}"
		$receivedData += data.bytesize
		send_data "#{data}"
		$sentData += data.bytesize
		#$log.info "#{$clientName}_OUT : #{data.bytesize}\n"
	end

	def unbind
		$clients -= 1
	end
end

#---Main
STDOUT.sync = true
EM.epoll

begin
	new_size = EM.set_descriptor_table_size( 100000 )
rescue Exception => e
	print_exception(e)
end

begin
	EM.run{
		EM.start_server '0.0.0.0', DEFAULT_PORT, EchoServer
		puts "Epoll Server Started on Port: #{DEFAULT_PORT}"
		$log.info "Epoll Server Started on Port: #{DEFAULT_PORT}"
	}
rescue SystemExit, Interrupt
	system( "clear" )
	puts "Maximum Connections: #{$totalConnections}"
	puts "User shutdown detected."
rescue Exception => e
	print_exception(e)
ensure
	sysExit
end
