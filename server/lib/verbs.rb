# DIARY A=ENTRY
define :diary do
    for word in tail do
        key, value = word.split('=')
        self.action = value if key == 'A'
    end
    client.puts self.action
end

define :echo do
    client.puts tail.join(" ")
end

define :ping do
    client.puts "PONG #{tail.join(" ")}".strip
end

define :end do
    client.puts "Halted."
    halt
end