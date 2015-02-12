require 'socket'
require 'thread'
require 'eventmachine'
require 'rubygems'

DEFAULT_PORT = 8005
SRV_IP = UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
#numOfClients = 0

def checkConnected
  var = Thread.new{
    while(true)
      sleep 15
      puts "Clients currently connected: #{numOfClients}"
    end
  }
end


module EchoServer
	$clients = 0
	def init
		#numOfClients = numOfClients + 1
		puts $clients += 1
		puts "conn: #{numOfClients}"

	end

	def receive_data data
		send_data data
		puts "Client says: #{data}"
	end

	def unbind
		#numOfClients = numOfClients - 1
		puts $clients -= 0
		puts "conn: #{numOfClients}"
	end
end

checkConnected

begin 
	EventMachine.epoll
	EventMachine.run {
		EventMachine.start_server '0.0.0.0', DEFAULT_PORT, EchoServer
		puts "Server started: #{SRV_IP}:#{DEFAULT_PORT}"
	}
rescue SystemExit, Interrupt 
	system("clear")
	puts "user shutdown detected."
rescue Exception => e
	#halt process bro
end
