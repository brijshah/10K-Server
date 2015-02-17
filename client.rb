#!/usr/bin/env ruby

require "socket"
require 'thread'
require 'thwait'
require 'logger'


#---Variables
DEFAULT_PORT = 8005
$totalClients = Integer(ARGV[2])
$ip = ARGV[0] 
$numberOfMessages = Integer(ARGV[1])
$clientNumber = 0
threads = Array::new

#--Create log file
log = Logger.new( 'client.txt' )


#---Prints exception to STDOUT
def print_exception(e)
	puts "error: #{e.message}"
end


#---Main
STDOUT.sync = true

while $clientNumber < $totalClients
	$clientNumber += 1
	puts "Client: #{$clientNumber}"

	threads = Thread.fork() do
		begin
			socket = TCPSocket.open($ip, DEFAULT_PORT)

			$numberOfMessages.times do
				socket.write "hello world, goodbye\n"
				response = socket.gets
				STDOUT.puts response
			end

			sleep
			#socket.close
		rescue Exception => e 
			print_exception(e)
			exit
		end
	end
	sleep(0.005)
end

STDIN.gets

ThreadsWait.all_waits(*threads)