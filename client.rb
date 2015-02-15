require "socket"
require 'thread'
require 'thwait'
require 'logger'


#---Variables
$totalClients = Integer(ARGV[1])
$ip = ARGV[0] 
$i = 0
threads = Array::new


#---Prints exception to STDOUT
def print_exception(e)
	puts "error: #{e.message}"
end

while $i < $totalClients
	puts $i += 1
	threads = Thread.fork() do
		begin
			socket = TCPSocket.open($ip, 8005)
			socket.puts "hello world, goodbye"
			line = socket.gets
			puts line
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