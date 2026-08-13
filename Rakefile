task :build do
    sh "rm diary" if File.file?('./diary')
    sh "nim c -d:release -d:ssl -o:diary diary.nim"
    sh "chmod +x diary"
    sh "mv diary /usr/local/bin/diary"
end

