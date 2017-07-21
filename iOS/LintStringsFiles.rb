#!/usr/bin/ruby
#file_description: This scripts checks for missing semicolons in .strings-files.

require 'optparse'
require 'ostruct'

def file_description()
  return File.open($0).each.map{ |l| l.strip }.select{ |line| line.start_with?("#file_description: ") }.first.split("#file_description: ").last
end

version = "0.0.2"

scriptFile = "LintStringsFiles.rb"
scriptSource = "https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/#{scriptFile}"

options = OpenStruct.new

OptionParser.new do |opts|
  opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
  end

  opts.on("-u", "--[no-]update", "Update Script") do |v|
    options.update = v
  end

  opts.on("-f x,y,z", "--filepaths x,y,z", Array, "Filepaths, split by ','") do |paths|
  options.file_paths = paths
  end


  opts.on_tail("-v", "--version", "Show version") do
     puts version
     exit
  end

end.parse!

if options.update
  puts "updating"
  exec("curl -L #{scriptSource}?$(date +%s) -o #{File.basename($0)}")
end

# Here begins the actual script

if options.file_paths
  exitcode = 0
  options.file_paths.each do |path|
      File.foreach(path).with_index do |line, line_num|
          if not line.strip.empty? and not line.strip.end_with?(";") and not (line.strip.start_with?("/*") and line.strip.end_with?("*/"))
              puts "#{path}:#{line_num+1}: error : semicolon missing"
              exitcode = 1
          end
      end
  end
  exit exitcode
else
  puts file_description
  puts "Error: no filepaths specified. see 'ruby #{$0} -h' for more options";
  exit 1
end
