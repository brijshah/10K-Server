#!/usr/bin/env ruby

#-----------------------------------------------------------------------------
#-- SOURCE FILE:    client.rb
#--
#-- PROGRAM:        Multi-Threaded Echo Client
#--
#-- FUNCTIONS:      
#--                 def print_exception(e)
#--					def current_time
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


#---Variables
DEFAULT_PORT = 8005
$clientNumber = 0
threads = Array::new

#--Create log file
$log = Logger.new("client #{Time.now}.txt")

#---Prints exception to STDOUT
def print_exception(e)
	puts "error: #{e.message}"
end

#---Retreives current time from machine
def current_time
	t = Time.now
	return t.strftime("%Y-%m-%d %H:%M:%S")
end

#---Main
STDOUT.sync = true

if ARGV.empty? || ARGV.count > 3
	puts "Proper usage: ruby client.rb server_addr [numberOfMessages] [numberOfClients]"
	exit
elsif ARGV.count == 1
	$ip = ARGV[0]
	$numberOfMessages = 1
	$totalClients = 1
elsif ARGV.count == 2
	$ip = ARGV[0]
	$numberOfMessages = Integer(ARGV[1])
	$totalClients = 1
elsif ARGV.count == 3
	$ip = ARGV[0]
	$numberOfMessages = Integer(ARGV[1])
	$totalClients = Integer(ARGV[2])
end

while $clientNumber < $totalClients
	$clientNumber += 1
	puts "Client: #{$clientNumber}"

	threads = Thread.fork() do
		begin
			socket = TCPSocket.open($ip, DEFAULT_PORT)
			time_out = Time.new

			time = Benchmark.measure do
				$numberOfMessages.times do
					message = "hello world, goodbye from #{$clientNumber}"
					$log.info "#{$clientNumber}: out,#{time_out = Time.now},#{message.bytesize}"
					socket.puts(message.chomp)
					response = socket.gets
					$log.info "#{$clientNumber}: in,#{Time.now},"
					STDOUT.puts response
				end
				$rtt = Time.new - time_out
			end
			$log.info "RTT: #{$rtt}"
			$log.info "Time to execute: #{time}"
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