#!/bin/env ruby

raise "Must provide one or more filenames!" if ARGV.empty?

inStyle = false
inJs = false

def _line_count(file)
  lines = `wc -l < #{file}`
  lines = lines.strip.to_i
end

ARGV.each do |full_filename|
  fname = File.basename(full_filename)
  puts "Processing #{full_filename}..."

  if _line_count(full_filename) < 4
    puts "    skipping processing! Too short."
    next
  end

  css_file = File.open("models/app.css", "w")
  js_file = File.open("models/app.js", "w")

  File.open("models/#{fname}", 'w') do |out|
    File.readlines(full_filename).each do |line|
      if line =~ /^\s+<\/head>$/
        out.write(%!<link rel="stylesheet" type="text/css" href="app.css" charset="utf-8"/>\n!)
        out.write(%!<link rel="stylesheet" type="text/css" href="app-custom.css" charset="utf-8"/>\n!)
      end

      if line =~ /^\s+<style>$/
        inStyle = true
        next
      end

      if line =~ /^\s+<\/style>$/
        inStyle = false
        next
      end

      if line =~ /^\/\/# END GLOBAL SCRIPTS$/
        inJs = false
        next
      end

      if line =~ /^\s+<script type="text\/javascript">$/
        inJs = true
        # inject the will-be-stripped common application code
        out.write(%!<script type="text/javascript" src="app.js"></script>\n!)
        out.write(line)
        next
      end

      if inStyle
        css_file.write(line)
      elsif inJs
        js_file.write(line)
      else
        out.write(line)
      end
    end
  end

  css_file.close
  js_file.close
end

