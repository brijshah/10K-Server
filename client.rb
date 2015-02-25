#!/usr/bin/env ruby

#-----------------------------------------------------------------------------
#-- SOURCE FILE:    client.rb
#--
#-- PROGRAM:        Multi-Threaded Echo Client
#--
#-- FUNCTIONS:      
#--                 def print_exception(e)
#--
#-- DATE:           February 17, 2015
#--
#--
#-- DESIGNERS:      Brij Shah
#--
#-- PROGRAMMERS:    Brij Shah
#--
#-- NOTES:
#-- This application with establish a TCP connection to a user specified
#-- server. The server can be specified by its IP address. The default 
#-- settings for this client will create 1 client and 1 message to send. 
#-- Each client establishes a new thread which will send the specified
#-- amount of messages to the server. 
#--
#-- This client can be deployed with the following servers included:
#-- mt_server.rb (Multi-Threaded)
#-- select_server.rb (Select)
#-- epoll_server.rb (Epoll)
#----------------------------------------------------------------------------*/

require "socket"
require 'thread'
require 'thwait'
require 'logger'
require 'benchmark'
require 'time'


#--- Variables
DEFAULT_PORT = 8005
$clientNumber = 0
threads = Array::new

#--- Creating Log File & set appropriate formatting
$log = Logger.new("client #{Time.now}.txt")

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
	puts "error: #{e.message}"
end

def message_generator(buffer_size)
	str = "A" * buffer_size
end

#--- Main
STDOUT.sync = true

if ARGV.empty? || ARGV.count > 4
	puts "Proper usage: ruby client.rb server_addr [numberOfMessages] [numberOfClients] [buffersize]"
	exit
elsif ARGV.count == 1 	#user specified svr + default port + 1 client
	$ip = ARGV[0]
	$numberOfMessages = 1 	
	$totalClients = 1
elsif ARGV.count == 2 	#user specified svr + user specified port + 1 client
	$ip = ARGV[0]
	$numberOfMessages = Integer(ARGV[1])
	$totalClients = 1
elsif ARGV.count == 3	#user specified svr + user specified port + user specified client
	$ip = ARGV[0]
	$numberOfMessages = Integer(ARGV[1])
	$totalClients = Integer(ARGV[2])
elsif ARGV.count == 4
	$ip = ARGV[0]
	$numberOfMessages = Integer(ARGV[1])
	$totalClients = Integer(ARGV[2])
	$buf = Integer(ARGV[3])
end

while $clientNumber < $totalClients
	$clientNumber += 1
	puts "Client: #{$clientNumber}"

	threads = Thread.fork() do
		begin
			socket = TCPSocket.open($ip, DEFAULT_PORT)
			time_out = Time.new

				$numberOfMessages.times do
					message = message_generator($buf).to_s
					$log.info "#{$clientNumber}: out,#{time_out = Time.now},#{message.bytesize}"
					socket.write(message)
					response = socket.read(message.bytesize)
					$log.info "#{$clientNumber}: in,#{Time.now},"
					STDOUT.puts response
				end
				$rtt = Time.new - time_out
			$log.info "RTT: #{$rtt}"
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