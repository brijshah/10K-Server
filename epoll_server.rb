require 'socket'
require 'thread'
require 'eventmachine'
require 'rubygems'
require 'logger'

#---Variables
DEFAULT_PORT = 8005
HOST = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
log = Logger.new( 'epoll_log.txt' )

#---Prints exception to STDOUT
def print_exception(e)
	puts "error: #{e.message}"
end

#---Module used with eventmachine. Provides common namespace for methods used with EM.
module EchoServer
	$clients = 0

	def init
		puts $clients += 1
	end

	def receive_data( data )
		send_data data
		puts "Client says: #{data.chomp}"
	end

	def unbind
		puts $clients -= 1
	end
end

#--Increase file descriptor limit
begin
	new_size = EM.set_descriptor_table_size( 10000 )
rescue Exception => e
	print_exception(e)
end

#---Main
begin
	EventMachine.epoll
	EventMachine.run {
		EventMachine.start_server '0.0.0.0', DEFAULT_PORT, EchoServer
		puts "Server started on: #{HOST}:#{DEFAULT_PORT}"
	}
rescue SystemExit, Interrupt #---Catches Ctrl-C
	system( "clear" )
rescue Exception => e
	print_exception(e)
end