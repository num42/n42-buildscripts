#!/usr/bin/ruby

require 'optparse'
require 'ostruct'

version = "0.0.2"

scriptFile = "ParallelSwiftlintAutocorrect.rb"
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

input_files = %x(find . | grep .swift$ | grep -v ./Carthage | grep -v ./fastlane | grep -v ./GeneratedCode ).split("\n")

hash = {}
threads = []

input_files.each_slice(30) do | slice |
    threads << Thread.new do
      slice.each_with_index do | filename, index |
        hash["SCRIPT_INPUT_FILE_#{index}"] = filename
      end

      hash["SCRIPT_INPUT_FILE_COUNT"] = slice.count.to_s

      system(hash, "swiftlint autocorrect --quiet --use-script-input-files")
    end
end

threads.each { |thr| thr.join }
