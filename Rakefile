task :build do
    sh "rm -f diary"
    sh "nim c -d:release -d:ssl -o:diary diary.nim"
    sh "chmod +x diary"
    sh "cp diary /usr/local/bin/diary"
end

SCP_DOMAIN   = "louis@louismachin.com"
EXTERNAL_DIR = "~/diary_backup"
DIARY_DIR    = ENV["DIARY_DIR"] || File.expand_path("~/.diary")
PARENT       = File.dirname(DIARY_DIR)
TARBALL      = "diary.tar.gz"

task :upload do
    require "time"
    folder         = File.basename(DIARY_DIR)
    timestamp      = Time.now.strftime("%Y%m%d_%H%M%S")
    dated_tarball  = "diary_#{timestamp}.tar.gz"

    sh "tar -czf #{dated_tarball} -C #{PARENT} #{folder}"
    sh "cp #{dated_tarball} #{TARBALL}"

    sh "ssh #{SCP_DOMAIN} 'mkdir -p #{EXTERNAL_DIR}'"
    sh "scp #{dated_tarball} #{SCP_DOMAIN}:#{EXTERNAL_DIR}/"
    sh "scp #{TARBALL} #{SCP_DOMAIN}:#{EXTERNAL_DIR}/"

    sh "rm -f #{dated_tarball} #{TARBALL}"
end

task :download do
    if Dir.exist?(DIARY_DIR)
        print "#{DIARY_DIR} already exists - overwrite its contents? [y/N] "
        answer = STDIN.gets.strip.downcase
        unless answer == "y"
            puts "Aborted, nothing changed."
            next
        end
    end

    sh "scp #{SCP_DOMAIN}:#{EXTERNAL_DIR}/#{TARBALL} #{TARBALL}"
    sh "tar -xzf #{TARBALL} -C #{PARENT}"
    sh "rm -f #{TARBALL}"

    puts "Restored diary entries to #{DIARY_DIR}"
end