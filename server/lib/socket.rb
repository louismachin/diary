server_thread = Thread.new do
    server = TCPServer.new('0.0.0.0', DIARY_PORT)
    puts "DIARY Protocol Server listening on port #{DIARY_PORT}..."

    loop do
        Thread.start(server.accept) do |client|
            begin
                client.puts "DIARY_v1.0_READY"
                payload = client.read

                puts "\n[RECEIVED PACKET]:"
                puts payload

                # Catch a dynamic loop interruption if 'END_DIARY' is called
                catch(:close_connection) do
                    payload.each_line do |line|
                        next if line.strip.empty?
                        parts = line.strip.split(" ")
                        verb, tail = parts[0].upcase, (parts[1..-1] || [])

                        context = ConnectionContext.new(client, verb, tail)

                        context.instance_eval do
                            not_verb unless $diary_verbs.key?(verb)
                            instance_eval(&$diary_verbs[verb])
                        end
                    end
                end
            rescue => e
                puts "Connection Error: #{e.message}"
            ensure
                client.close
            end
        end
    end
end

server_thread.join