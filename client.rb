#!/usr/bin/ruby

require 'socket'

puts "Enter message to send: "
message = STDIN.gets.chomp

puts "Number of times to send: "
numMsg = STDIN.gets.chomp.to_i


begin
	socket = TCPSocket.open("localhost", 8000)
rescue Exception => e 
	puts "error: #{e.message}"
	exit
end
begin
	(1..numMsg).each do |i|
		socket.puts message
		resp = socket.readline
		puts resp
	end
rescue Exception => e
	puts "error: #{e.message}"
ensure
	socket.close
end

