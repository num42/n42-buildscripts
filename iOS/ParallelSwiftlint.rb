#!/usr/bin/ruby

require 'optparse'
require 'ostruct'

version = "0.0.1"

scriptFile = "ParallelSwiftlint.rb"
scriptSource = "https://raw.githubusercontent.com/num42/n42-buildscripts/master/iOS/#{scriptFile}"

options = OpenStruct.new

options.update = false
options.numberOfGroups = 4
    
OptionParser.new do |opts|
  
  opts.on("-g", "--groups=val", Integer) do |numberOfGroups|
    options.numberOfGroups = numberOfGroups
  end
  
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

input_files = %x(find . | grep .swift$ | grep -v ./Carthage | grep -v ./fastlane | grep -v ./Pods | grep -v ./GeneratedCode ).split("\n").shuffle()

hash = {}
threads = []

module Enumerable
  def every_nth(n, offset)
    (0... self.length).select{ |x| x%n == n-1 }.map { |y| self[y - offset] }
  end
end

1.upto(options.numberOfGroups) do | group |
    slice = input_files.every_nth(options.numberOfGroups, group).map { |line| line.split(" ").last}
    
    threads << Thread.new do
      slice.each_with_index do | filename, index |
        hash["SCRIPT_INPUT_FILE_#{index}"] = filename
      end
    
      hash["SCRIPT_INPUT_FILE_COUNT"] = slice.count.to_s
      system(hash, "swiftlint autocorrect --quiet --use-script-input-files; swiftlint --quiet --use-script-input-files --enable-all-rules")
    end

end

threads.each { |thr| thr.join }
