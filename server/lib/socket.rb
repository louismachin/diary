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

                lines = payload.lines.map(&:chomp)
                split_at = lines.index { |l| l.strip.empty? }

                header = split_at ? lines[0...split_at]     : lines
                body   = split_at ? lines[(split_at + 1)..] : []

                context = ConnectionContext.new(client, body)

                catch(:close_connection) do
                    header.each do |line|
                        parts = line.strip.split(" ")
                        context.verb = parts[0].upcase
                        context.tail = parts[1..] || []

                        context.not_verb unless $diary_verbs.key?(context.verb)
                        context.instance_eval(&$diary_verbs[context.verb])
                        puts "ACTION=#{context.action}; BODY=#{context.body}"
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