task :build do
    sh "rm -f diary"
    sh "nim c -d:release -d:ssl -o:diary diary.nim"
    sh "chmod +x diary"
    sh "cp diary /usr/local/bin/diary"
end

