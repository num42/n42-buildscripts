#!/usr/bin/ruby

require 'optparse'
require 'ostruct'

version = "0.0.1"

scriptFile = "ParallelSwiftformat.rb"
scriptSource = "https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/#{scriptFile}"

options = OpenStruct.new

options.update = false
    
OptionParser.new do |opts|
  opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
  end
    
  opts.on("-u", "--[no-]update", "Update Script") do |v|
    options.update = v
  end
   
  opts.on_tail("--version", "Show version") do
     puts version
     exit
  end
   
end.parse!

if options.update
  puts "updating"
  exec("curl -L #{scriptSource}?$(date +%s) -o #{File.basename($0)}")
end

# Here begins the actual script

input_files = %x(find . | grep .swift$ | grep -v ./Carthage | grep -v ./fastlane ).split("\n").shuffle()

hash = {}
threads = []

input_files.each_slice(20) do | slice |
    threads << Thread.new do
      system("/usr/local/bin/swiftformat --disable redundantSelf --cache ignore --indent 2 --wraparguments beforefirst --wrapelements beforefirst --header ignore --patternlet inline --stripunusedargs closure-only --insertlines disabled --commas inline #{slice.map { |file| "\"#{file}\"" }.join(" ")}")
    end
end

threads.each { |thr| thr.join }
