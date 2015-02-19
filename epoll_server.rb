#!/usr/bin/env ruby

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

#--Creating log file
$log = Logger.new('epoll_log.txt')

#--Prints exception to STDOUT
def print_exception(e)
	puts "#{e.message}"
end

def clientHandler()
	port, ip = Socket.unpack_sockaddr_in(get_peername)
	$clientName = "#{ip}:#{port}"
	puts "#{$clientName} connected"
end

#---Module used with eventmachine.
module EchoServer
	$clients = 0

	def post_init
		clientHandler
		$log.info "#{$clientName} connected"
		$clients += 1
		$totalConnections += 1
	end

	def receive_data data
		$log.info "#{$clientName}_IN : #{data.bytesize}"
		$receivedData += data.bytesize
		send_data "#{data}"
		$sentData += data.bytesize
		$log.info "#{$clientName}_OUT : #{data.bytesize}"
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
	$log.info "Epoll Server Stopped"
	$log.info "Total bytes transferred in: #{$receivedData}"
	$log.info "Total bytes transferred out: #{$sentData}"
	$log.info "Total bytes transferred: #{$receivedData + $sentData}"
rescue Exception => e
	print_exception(e)
end
