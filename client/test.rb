require 'socket'
require 'uri'

def send_diary_packet(uri_string, data = {})
    uri = URI.parse(uri_string)
    raise "Unsupported protocol scheme: #{uri.scheme}" unless uri.scheme == 'diary'
  
    host = uri.host
    port_path = File.join(__dir__, '..', 'server', '.port')
    port = File.read(port_path) || 1734

    packet =  "PING\n"
    packet << "DIARY V=1\n"
    packet << "ECHO THIS IS A TEST\n"
    packet << "FOOBAR\n"
    packet << "END_DIARY\n"

    puts "Connecting to custom protocol layer at #{host}:#{port}..."

    begin
        socket = TCPSocket.new(host, port)
        # Read the server's initial connection greeting (e.g., "CONNECT_OK DIARY/1.0")
        server_greeting = socket.gets
        puts "Server Greeting: #{server_greeting.strip}"
        # Stream the custom packet data
        puts "Streaming custom packet fields..."
        socket.write(packet)
        # Tell the server we have finished writing so it knows to process it
        socket.close_write 
        # Capture the server's custom status response
        response = socket.read
        puts "Server Response: #{response.strip}"
    rescue Errno::ECONNREFUSED
        puts "Error: Could not connect. Is the Sinatra TCP server running on port #{port}?"
    rescue => e
        puts "An error occurred transmission: #{e.message}"
    ensure
        socket.close if socket && !socket.closed?
    end
end

diary_entry = {
    gregorian: "2026-10-16 17:34:00",
    lunar: "Year 4724, Month 9, Day 6",
    mood: "Inspired",
    content: "Successfully decoupled from HTTP. Sending data over a pure custom Ruby TCP socket layer!"
}

# send_diary_packet("diary://louismachin.com", diary_entry)
send_diary_packet("diary://localhost", diary_entry)