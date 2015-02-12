#!/usr/bin/ruby

require 'socket'
require 'thread'

puts "Enter IP Address: "
IP = STDIN.gets.chomp

puts "Enter message to send: "
message = STDIN.gets.chomp

puts "Number of times to send message: "
numMsg = STDIN.gets.chomp.to_i

puts "Number of clients to create: "
numOfClients = STDIN.gets.chomp.to_i

threads = (1..numOfClients).map do |t|
	Thread.new(t) do |t|
		begin
			@socket = TCPSocket.open(IP, 8005)
		rescue Exception => e 
			puts "error: #{e.message}"
			exit
		end
		begin
			(1..numMsg).each do |i|
				@socket.puts message
				resp = @socket.readline
				puts resp
			end
		rescue Exception => e
			puts "error1: #{e.message}"
		end
	end
end

threads.each {|t| t.join}

puts "Enter exit to close client(s).."
close = STDIN.gets.chomp
if close.include? ("exit")
	puts "closing connection"
	@socket.close
end

