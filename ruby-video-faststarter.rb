# Author: Ivan Teplyakov (iteplyakov.ru)
# Github: https://github.com/ExReanimator
#
# Usage:
# ruby ruby-video-faststarter.rb <source_dir> [<destination_dir>]
#
# TODO:
# Processing with subdirectories

require 'fileutils'

srcdir = ARGV[0] or raise ArgumentError, "the first param must be a source directory", caller
rewrite = false

if ARGV[1]
  dstdir = ARGV[1]
else
  puts "Are you shure want to overwrite source files? [y/N] (default: No):"
  unless $stdin.gets.chomp == 'y'
    raise ArgumentError, "otherwise the second param must be a destination directory", caller
  end
  rewrite = true
  
  # if destination directory hasn't set, use /tmp directory for middle-processing place
  dstdir = '/tmp/'
end

# for convenience cut last slash of source directory if exist
srcdir.chop! if srcdir[-1] == '/'

# and add it for destination directory
dstdir << '/' unless dstdir[-1] == '/'

# read mp4 or mov video
files = Dir[srcdir + "/*.{mp4,mov}"]
total = files.count

raise RuntimeError, "Nothing to do in dir: " + srcdir, caller if total == 0

puts "Founded: " + total.to_s + " videos"
puts "Starting..."

files.each do |video|
  filename = File.basename(video).to_s
  puts "Remained: " + total.to_s
  puts "-- Processing " + filename
  
  # execute qt-faststart from ffmpeg package
  result = %x(qt-faststart #{video} #{dstdir}#{filename})
  
  if result.to_s =~ /copying rest of file/
    puts "video was successfully faststarted!"
    
    # move from temporary dir to source dir if need to overwrite sources
    FileUtils.mv dstdir + filename, video if rewrite  
  else  
    puts "already faststarted"
    
    # qt-faststart don't process file if it's already faststarted
    # So, move source files to destination dir if source and destinations dir are not same
    FileUtils.mv video, dstdir + filename unless rewrite
  end
  total -= 1
end
