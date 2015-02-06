#!/user/bin/ruby

require 'socket'
require 'thread'

puts "Starting Server.."

server = TCPServer.new(8005)
@numOfClients = 0

while(session = server.accept)
    Thread.start do
        puts "Connection from: #{session.peeraddr[2]}"
        @numOfClients = @numOfClients + 1
        puts "Number of clients connected: #{@numOfClients}"
        begin
            loop do
                message = session.gets
                puts "CLIENT > #{message}"
                session.puts "SERVER > #{message}"
            end
        rescue EOFError
            session.close
            @numOfClients = @numOfClients -1
            puts "Number of clients connected: #{@numOfClients}"
        end
    end
end