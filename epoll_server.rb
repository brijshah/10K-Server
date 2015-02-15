require 'socket'
require 'thread'
require 'eventmachine'
require 'rubygems'

#---Variables
DEFAULT_PORT = 8005
HOST = 'localhost'

module EchoServer
	$clients = 0

	def init
		puts $clients += 1
	end

	def receive_data( data )
		send_data data
		puts "Client says: #{data}"
	end

	def unbind
		puts $clients -= 1
	end
end

#--Increase file descriptor limit
begin
	new_size = EM.set_descriptor_table_size( 10000 )
rescue Exception => e
	puts "Error: #{e.message}"
end

#---Main
begin
	EventMachine.epoll
	EventMachine.run {
		EventMachine.start_server '0.0.0.0', DEFAULT_PORT, EchoServer
		puts "Server started on: #{HOST}:#{DEFAULT_PORT}"
	}
rescue SystemExit, Interrupt
	system( "clear" )
rescue Exception => e
	puts "Error: #{e.message}"
end