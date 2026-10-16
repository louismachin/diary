define :echo do
    client.puts tail.join(" ")
end

define :ping do
    client.puts "PONG #{tail.join(" ")}".strip
end

define :end_diary do
    client.puts "SUCCESS"
    halt
end

define :diary do
    version = tail[0].split('=')[1]
    client.puts version
end