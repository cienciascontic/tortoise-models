#!/bin/env ruby

raise "Must provide one or more filenames!" if ARGV.empty?

inStyle = false
inJs = false

ARGV.each do |full_filename|
  fname = File.basename(full_filename)
  File.open("models/#{fname}", 'w') do |out|
    File.readlines(full_filename).each do |line|
      if line =~ /^\s+<\/head>$/
        out.write(%!<link rel="stylesheet" type="text/css" href="app.css" charset="utf-8"/>\n!)
      end

      if line =~ /^\s+<style>$/
        inStyle = true
      end

      if line =~ /^\s+<\/style>$/
        inStyle = false
        next
      end

      if line =~ /^\/\/# sourceMappingURL=highchartsops.js.map$/
        inJs = false
        next
      end

      if line =~ /^\s+<script type="text\/javascript">$/
        inJs = true
        # inject the will-be-stripped common application code
        out.write(%!<script type="text/javascript" src="app.js"></script>\n!)
        out.write(line)
      end

      next if inStyle
      next if inJs

      out.write(line)
    end
  end
end
