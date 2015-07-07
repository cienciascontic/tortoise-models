#!/bin/env ruby
FORCE = !ARGV.delete('--force').nil?
if ARGV.empty?
  puts "Converting all nlogo files..."
else
  puts "Converting specified nlogo files..."
end

DEBUG = false

CUSTOM_COMMANDS = {
  "myHideSpeedSlider" => "my-hide-speed-slider.js",
  "myImportDrawing" => "my-import-drawing.js",
  "myAcos" => "acos.js",
  "pause" => "pause.js",
  "myApproximateRgb" => "approximate-rgb.js",
  "myHsb" => "hsb.js"
}

def inject_custom_commands(file)
  CUSTOM_COMMANDS.each do |k,v|
    grp = `grep 'var #{k} = function(' #{file}`
    unless grp.empty?
      puts "overriding command #{k}"
      lines = `wc -l < #{file}`
      lines = lines.strip.to_i
      _inject(file, lines-4, "commands/#{v}")
    end
  end
end

def inject_patches(file)
  line = `awk '/# sourceMappingURL=highchartsops.js.map/{ print NR; exit }' #{file}`
  line = line.strip.to_i
  # since we're injecting patches always at the same line, patches will end up in the final file in *reverse* order
  # of the order that _inject is called (first injected will end up last in the resulting file)

  # Inject a placeholder so that the process script knows where to cut for the global shared scripts
  _inject(file, line, 'misc/end_global_scripts_marker.js')

  Dir.glob('patches/*js').each do |patch|
    puts "applying patch #{patch}"
    _inject(file, line, patch)
  end
end

def inject_shutterbug(file)
  puts "injecting shutterbug"
  lines = _line_count(file)
  _inject(file, lines-2, "misc/shutterbug.html")
end

def _inject(file, line, source)
  puts "injecting #{source} at line #{line}" if DEBUG
  `head -n #{line} #{file} > #{file}.tmp`
  `cat #{source} >> #{file}.tmp`
  `tail -n +#{line+1} #{file} >> #{file}.tmp`
  `cp #{file}.tmp #{file}`
  `rm #{file}.tmp`
end

def _line_count(file)
  lines = `wc -l < #{file}`
  lines = lines.strip.to_i
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
  file = 'standalone/'+fname
  cache_file = 'cache/'+fname

  Dir.mkdir 'cache' rescue nil

  puts "Converting #{full_filename}..."
  if FORCE || !File.exists?(cache_file)
    puts `#{curl_command(full_filename, cache_file)}`
  end
  `cp #{cache_file} #{file}`

  if _line_count(file) > 4
    inject_patches(file)
    inject_custom_commands(file)
    _inject(file, _line_count(file)-4, "misc/startup-workaround.js")
    inject_shutterbug(file)
  end
end
