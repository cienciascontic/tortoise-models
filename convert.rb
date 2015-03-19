#!/bin/env ruby

if ARGV.empty?
  puts "Converting all nlogo files..."
else
  puts "Converting specified nlogo files..."
end

def curl_command(in_file, out_file)
  cmd = %!curl -F model=@#{in_file} "http://li425-91.members.linode.com:9000/save-nlogo"!
  cmd += ' -H "Origin: http://li425-91.members.linode.com:9000"'
  cmd += ' -H "Accept-Encoding: gzip, deflate"'
  cmd += ' -H "Accept-Language: en-US,en;q=0.8"'
  cmd += ' -H "User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.89 Safari/537.36"'
  cmd += ' -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"'
  cmd += ' -H "Cache-Control: max-age=0"'
  cmd += ' -H "Referer: http://li425-91.members.linode.com:9000/create-standalone"'
  cmd += %! -o "#{out_file}"!
  cmd += ' --compressed'
end

files = ARGV.empty? ? Dir.glob('nlogo/*nlogo') : ARGV

files.each do |full_filename|
  fname = File.basename(full_filename).gsub(/nlogo$/,'html')

  puts `#{curl_command(full_filename, 'standalone/'+fname)}`
end
