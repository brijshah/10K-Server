require "socket"
require 'thread'
require 'thwait'
require 'logger'


#---Variables
$totalClients = Integer(ARGV[1])
$ip = ARGV[0] 
$var = 0
threads = Array::new
log = Logger.new( 'client.txt' )


#---Prints exception to STDOUT
def print_exception(e)
	puts "error: #{e.message}"
end


#---Main
while $var < $totalClients
	$var += 1
	puts "Client: #{$var}"
	threads = Thread.fork() do
		begin
			socket = TCPSocket.open($ip, 8005)
			socket.puts "hello world, goodbye\n"
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